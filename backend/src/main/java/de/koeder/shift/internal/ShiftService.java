package de.koeder.shift.internal;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.TreeMap;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import de.koeder.content.Evaluation;
import de.koeder.content.PublicScenario;
import de.koeder.content.Scenario;
import de.koeder.content.ScenarioCatalog;
import de.koeder.content.ScenarioEvaluator;
import de.koeder.identity.IdentityApi;
import de.koeder.identity.UserRef;
import de.koeder.shift.ScenarioAnswered;
import de.koeder.shift.ShiftApi;
import de.koeder.shift.ShiftCompleted;

@Service
class ShiftService implements ShiftApi {

    static final int SWIPE_ROUNDS_PER_DAY = 3;
    static final int SWIPE_DECK_SIZE = 20;

    private final JdbcClient jdbc;
    private final ScenarioCatalog catalog;
    private final IdentityApi identity;
    private final ApplicationEventPublisher events;
    private final Clock clock;
    private final boolean demo;

    ShiftService(JdbcClient jdbc, ScenarioCatalog catalog, IdentityApi identity, ApplicationEventPublisher events, Clock clock,
                 @Value("${koeder.demo.enabled}") boolean demo) {
        this.jdbc = jdbc;
        this.catalog = catalog;
        this.identity = identity;
        this.events = events;
        this.clock = clock;
        this.demo = demo;
    }

    record TodayShift(UUID id, LocalDate date, boolean completed, int score, List<PublicScenario> scenarios, List<String> answered) {
    }

    record ActionResult(Evaluation evaluation, int answered, int total, boolean shiftCompleted) {
    }

    @Transactional
    TodayShift today(UUID userId) {
        LocalDate date = LocalDate.now(clock);
        UserRef user = identity.require(userId);
        ShiftRow row = findShift(userId, date);
        if (row == null || row.scenarios.isEmpty()) {
            row = createShift(user, date, row);
        }
        List<PublicScenario> scenarios = row.scenarios.stream()
                .map(id -> catalog.find(id, user.locale()))
                .flatMap(java.util.Optional::stream)
                .map(Scenario::toPublic)
                .toList();
        return new TodayShift(row.id, date, row.completed, row.score, scenarios, answeredIn(row.id));
    }

    private ShiftRow createShift(UserRef user, LocalDate date, ShiftRow existing) {
        Set<String> seen = new HashSet<>(jdbc.sql("""
                SELECT DISTINCT scenario_id FROM attempts WHERE user_id = :u AND created_at > now() - interval '14 days'
                """).param("u", user.id()).query(String.class).list());
        boolean first = !jdbc.sql("SELECT 1 FROM attempts WHERE user_id = :u AND shift_id IS NOT NULL LIMIT 1")
                .param("u", user.id()).query(Integer.class).optional().isPresent();
        long xp = jdbc.sql("SELECT coalesce(sum(points), 0) / 5 FROM attempts WHERE user_id = :u").param("u", user.id()).query(Long.class).single();
        int level = 1 + (int) (xp / 300);
        long seed = user.id().getMostSignificantBits() ^ date.toEpochDay();
        List<String> plan = ShiftPlanner.plan(catalog.pool(user.locale(), user.orgId()), seen, first, "simple".equals(user.mode()), level, seed);
        String joined = String.join(",", plan);
        UUID id = existing != null ? existing.id : UUID.randomUUID();
        // Two tabs may open today's shift at once: the unique index decides, the loser reads the winner's row.
        jdbc.sql("""
                INSERT INTO daily_shifts (id, user_id, date, scenarios) VALUES (:id, :u, :d, :s)
                ON CONFLICT (user_id, date) DO UPDATE SET scenarios = CASE WHEN daily_shifts.scenarios = '' THEN :s ELSE daily_shifts.scenarios END
                """).param("id", id).param("u", user.id()).param("d", Date.valueOf(date)).param("s", joined).update();
        return findShift(user.id(), date);
    }

    @Transactional
    ActionResult act(UUID userId, UUID shiftId, String scenarioId, String action, long ms) {
        ShiftRow row = jdbc.sql("SELECT id, user_id, scenarios, completed, score, correct FROM daily_shifts WHERE id = :id AND user_id = :u")
                .param("id", shiftId).param("u", userId).query(ShiftService::mapShift).optional()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        if (!row.scenarios.contains(scenarioId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "scenario is not part of this shift");
        }
        UserRef user = identity.require(userId);
        Scenario s = scenario(scenarioId, user);
        // The server clock is what counts in competition; in a shift the client's reading time is only a small bonus.
        Evaluation e = ScenarioEvaluator.evaluateAction(s, action, Math.clamp(ms, 0L, 600_000L));
        try {
            record(user, s, e, action, ms, shiftId, "shift");
        } catch (DuplicateKeyException dup) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "already answered");
        }
        jdbc.sql("UPDATE daily_shifts SET score = score + :p, correct = correct + :c WHERE id = :id")
                .param("p", e.points()).param("c", e.correct() ? 1 : 0).param("id", shiftId).update();

        int answered = answeredIn(shiftId).size();
        int total = row.scenarios.size();
        boolean done = answered >= total;
        if (done && !row.completed) {
            jdbc.sql("UPDATE daily_shifts SET completed = true WHERE id = :id").param("id", shiftId).update();
            ShiftTotals totals = jdbc.sql("SELECT score, correct FROM daily_shifts WHERE id = :id").param("id", shiftId)
                    .query((rs, n) -> new ShiftTotals(rs.getInt(1), rs.getInt(2))).single();
            events.publishEvent(new ShiftCompleted(userId, LocalDate.now(clock), totals.score, totals.correct, total));
        }
        return new ActionResult(e, answered, total, done);
    }

    private record ShiftTotals(int score, int correct) {
    }

    /** Practice modes (review queue, module lessons) are not limited: base learning stays free. */
    @Transactional
    Evaluation practice(UUID userId, String scenarioId, String context, String action, List<String> flags, long ms) {
        UserRef user = identity.require(userId);
        Scenario s = scenario(scenarioId, user);
        Evaluation e = switch (context) {
            case "swipe" -> ScenarioEvaluator.evaluateVerdict(s, action, ms);
            case "flags" -> ScenarioEvaluator.evaluateFlags(s, flags == null ? List.of() : flags);
            default -> ScenarioEvaluator.evaluateAction(s, action, ms);
        };
        record(user, s, e, action, ms, null, context);
        return e;
    }

    private void record(UserRef user, Scenario s, Evaluation e, String action, long ms, UUID shiftId, String context) {
        jdbc.sql("""
                INSERT INTO attempts (id, user_id, scenario_id, locale, shift_id, context, action, outcome, is_correct, points, response_ms, flags_found)
                VALUES (:id, :u, :s, :l, :shift, :ctx, :a, :o, :c, :p, :ms, :f)
                """)
                .param("id", UUID.randomUUID()).param("u", user.id()).param("s", s.id()).param("l", s.locale())
                .param("shift", shiftId, java.sql.Types.OTHER).param("ctx", context).param("a", action == null ? "" : action)
                .param("o", e.outcome().name()).param("c", e.correct()).param("p", e.points())
                .param("ms", (int) Math.clamp(ms, 0L, Integer.MAX_VALUE)).param("f", e.flagsFound()).update();
        updateReviewQueue(user.id(), s.id(), e.correct(), "review".equals(context));
        events.publishEvent(new ScenarioAnswered(user.id(), s.id(), context, s.statsBucket(), s.attack(), e.outcome().name(),
                e.correct(), e.reported(), e.xp(), e.coins()));
    }

    private void updateReviewQueue(UUID userId, String scenarioId, boolean correct, boolean isReview) {
        Integer box = jdbc.sql("SELECT box FROM review_queue WHERE user_id = :u AND scenario_id = :s")
                .param("u", userId).param("s", scenarioId).query(Integer.class).optional().orElse(null);
        if (box == null && correct) {
            return; // never missed: nothing to repeat
        }
        // Only an actual review moves a card up; getting it right by chance elsewhere must not shorten the schedule.
        if (box != null && correct && !isReview) {
            return;
        }
        var next = Leitner.nextBox(box == null ? 0 : box, correct);
        if (next.isEmpty()) {
            jdbc.sql("DELETE FROM review_queue WHERE user_id = :u AND scenario_id = :s").param("u", userId).param("s", scenarioId).update();
            return;
        }
        Instant due = clock.instant().plus(Leitner.interval(next.get()));
        jdbc.sql("""
                INSERT INTO review_queue (user_id, scenario_id, box, due_at) VALUES (:u, :s, :b, :d)
                ON CONFLICT (user_id, scenario_id) DO UPDATE SET box = :b, due_at = :d
                """).param("u", userId).param("s", scenarioId).param("b", next.get()).param("d", Timestamp.from(due)).update();
    }

    @Transactional(readOnly = true)
    List<PublicScenario> reviewDue(UUID userId) {
        UserRef user = identity.require(userId);
        return jdbc.sql("SELECT scenario_id FROM review_queue WHERE user_id = :u AND due_at <= :now ORDER BY due_at LIMIT 10")
                .param("u", userId).param("now", Timestamp.from(clock.instant())).query(String.class).list().stream()
                .map(id -> catalog.find(id, user.locale())).flatMap(java.util.Optional::stream).map(Scenario::toPublic).toList();
    }

    /** Swipe deck: consumes one of the free daily rounds. */
    @Transactional
    List<PublicScenario> swipeDeck(UUID userId) {
        UserRef user = identity.require(userId);
        LocalDate date = LocalDate.now(clock);
        ShiftRow row = findShift(userId, date);
        if (row == null) {
            jdbc.sql("INSERT INTO daily_shifts (id, user_id, date, scenarios) VALUES (:id, :u, :d, '') ON CONFLICT DO NOTHING")
                    .param("id", UUID.randomUUID()).param("u", userId).param("d", Date.valueOf(date)).update();
        }
        int used = jdbc.sql("UPDATE daily_shifts SET swipe_rounds = swipe_rounds + 1 WHERE user_id = :u AND date = :d AND swipe_rounds < :max")
                .param("u", userId).param("d", Date.valueOf(date)).param("max", SWIPE_ROUNDS_PER_DAY).update();
        if (used == 0) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "swipe rounds used up today");
        }
        return swipePool(user);
    }

    private List<PublicScenario> swipePool(UserRef user) {
        List<Scenario> pool = new ArrayList<>(catalog.pool(user.locale(), user.orgId()).stream()
                .filter(s -> !s.type().equals("call") && !s.type().equals("scene"))
                .filter(s -> !"simple".equals(user.mode()) || s.consumer())
                .toList());
        Collections.shuffle(pool, new Random());
        return pool.stream().limit(SWIPE_DECK_SIZE).map(Scenario::toPublic).toList();
    }

    @Transactional(readOnly = true)
    List<PublicScenario> flagsDeck(UUID userId) {
        UserRef user = identity.require(userId);
        List<Scenario> pool = new ArrayList<>(catalog.pool(user.locale(), user.orgId()).stream()
                .filter(s -> s.type().equals("email") && s.attack() && s.redFlags().size() >= 2).toList());
        Collections.shuffle(pool, new Random());
        return pool.stream().limit(5).map(Scenario::toPublic).toList();
    }

    @Transactional(readOnly = true)
    List<PublicScenario> moduleLesson(UUID userId, int module) {
        UserRef user = identity.require(userId);
        return catalog.pool(user.locale(), user.orgId()).stream()
                .filter(s -> s.module() == module)
                .sorted((a, b) -> Integer.compare(ShiftPlanner.difficultyRank(a.difficulty()), ShiftPlanner.difficultyRank(b.difficulty())))
                .map(Scenario::toPublic).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Energy energy(UUID userId) {
        ShiftRow row = findShift(userId, LocalDate.now(clock));
        int swipes = row == null ? 0 : jdbc.sql("SELECT swipe_rounds FROM daily_shifts WHERE id = :id").param("id", row.id).query(Integer.class).single();
        boolean done = row != null && row.completed;
        return new Energy(!done, done, SWIPE_ROUNDS_PER_DAY - swipes, SWIPE_ROUNDS_PER_DAY);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<Integer, Integer> moduleProgress(UUID userId) {
        UserRef user = identity.require(userId);
        Set<String> solved = new HashSet<>(jdbc.sql("SELECT DISTINCT scenario_id FROM attempts WHERE user_id = :u AND is_correct")
                .param("u", userId).query(String.class).list());
        Map<Integer, Integer> out = new TreeMap<>();
        for (Scenario s : catalog.pool(user.locale(), user.orgId())) {
            if (solved.contains(s.id())) {
                out.merge(s.module(), 1, Integer::sum);
            }
        }
        return out;
    }

    @Override
    @Transactional(readOnly = true)
    public long reviewsDue(UUID userId) {
        return jdbc.sql("SELECT count(*) FROM review_queue WHERE user_id = :u AND due_at <= :now")
                .param("u", userId).param("now", Timestamp.from(clock.instant())).query(Long.class).single();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> exportAttempts(UUID userId) {
        return jdbc.sql("SELECT scenario_id, context, action, outcome, is_correct, points, response_ms, created_at FROM attempts WHERE user_id = :u ORDER BY created_at")
                .param("u", userId).query().listOfRows();
    }

    /** Lets the team replay the daily shift on stage. Only available while the demo configuration is on. */
    @Override
    @Transactional
    public void demoReset(UUID userId) {
        if (!demo) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        jdbc.sql("DELETE FROM daily_shifts WHERE user_id = :u AND date = :d").param("u", userId).param("d", Date.valueOf(LocalDate.now(clock))).update();
        jdbc.sql("UPDATE review_queue SET due_at = :now WHERE user_id = :u").param("u", userId).param("now", Timestamp.from(clock.instant())).update();
    }

    private Scenario scenario(String id, UserRef user) {
        Scenario s = catalog.find(id, user.locale()).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        // A company scenario is confidential to that company: an id alone must not unlock it.
        if (s.orgId() != null && !s.orgId().equals(user.orgId())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        return s;
    }

    private ShiftRow findShift(UUID userId, LocalDate date) {
        return jdbc.sql("SELECT id, user_id, scenarios, completed, score, correct FROM daily_shifts WHERE user_id = :u AND date = :d")
                .param("u", userId).param("d", Date.valueOf(date)).query(ShiftService::mapShift).optional().orElse(null);
    }

    private List<String> answeredIn(UUID shiftId) {
        return jdbc.sql("SELECT scenario_id FROM attempts WHERE shift_id = :id").param("id", shiftId).query(String.class).list();
    }

    private static ShiftRow mapShift(java.sql.ResultSet rs, int n) throws java.sql.SQLException {
        String joined = rs.getString("scenarios");
        List<String> ids = joined.isEmpty() ? List.of() : Arrays.asList(joined.split(","));
        return new ShiftRow(rs.getObject("id", UUID.class), ids, rs.getBoolean("completed"), rs.getInt("score"));
    }

    private record ShiftRow(UUID id, List<String> scenarios, boolean completed, int score) {
    }
}
