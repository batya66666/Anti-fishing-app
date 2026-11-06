package de.koeder.shift.internal;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
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

    static final int SWIPE_DECK_SIZE = 20;
    static final int ENDLESS_BATCH = 10;

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
        if (row == null) {
            row = createShift(user, date, 1);
        } else {
            row = applyForcedDifficulty(user, row);
        }
        return toResponse(user, date, row);
    }

    /** As many shifts a day as you like. A running shift is finished first. */
    @Transactional
    TodayShift nextShift(UUID userId) {
        LocalDate date = LocalDate.now(clock);
        UserRef user = identity.require(userId);
        ShiftRow row = findShift(userId, date);
        if (row == null) {
            return today(userId);
        }
        return toResponse(user, date, row.completed ? createShift(user, date, row.round + 1) : row);
    }

    /** A manager just changed the level for a demonstration: a shift nobody has touched yet follows at once. */
    private ShiftRow applyForcedDifficulty(UserRef user, ShiftRow row) {
        String forced = catalog.forcedDifficulty(user.orgId()).orElse(null);
        if (forced == null || row.completed || !answeredIn(row.id).isEmpty()) {
            return row;
        }
        boolean fits = row.scenarios.stream().map(id -> catalog.find(id, user.locale())).flatMap(java.util.Optional::stream).allMatch(s -> s.fitsDifficulty(forced));
        if (fits) {
            return row;
        }
        jdbc.sql("UPDATE daily_shifts SET scenarios = :s WHERE id = :id").param("s", String.join(",", planFor(user, LocalDate.now(clock), row.round))).param("id", row.id).update();
        return findShift(user.id(), LocalDate.now(clock));
    }

    private TodayShift toResponse(UserRef user, LocalDate date, ShiftRow row) {
        List<PublicScenario> scenarios = row.scenarios.stream()
                .map(id -> catalog.find(id, user.locale()))
                .flatMap(java.util.Optional::stream)
                .map(Scenario::toPublic)
                .toList();
        return new TodayShift(row.id, date, row.completed, row.score, scenarios, answeredIn(row.id));
    }

    private ShiftRow createShift(UserRef user, LocalDate date, int round) {
        String joined = String.join(",", planFor(user, date, round));
        // Two tabs may open the same shift at once: the unique index decides, the loser reads the winner's row.
        jdbc.sql("""
                INSERT INTO daily_shifts (id, user_id, date, round, scenarios) VALUES (:id, :u, :d, :r, :s)
                ON CONFLICT (user_id, date, round) DO NOTHING
                """).param("id", UUID.randomUUID()).param("u", user.id()).param("d", Date.valueOf(date)).param("r", round).param("s", joined).update();
        return findShift(user.id(), date);
    }

    private List<String> planFor(UserRef user, LocalDate date, int round) {
        Set<String> seen = new HashSet<>(jdbc.sql("""
                SELECT DISTINCT scenario_id FROM attempts WHERE user_id = :u AND created_at > now() - interval '14 days'
                """).param("u", user.id()).query(String.class).list());
        boolean first = !jdbc.sql("SELECT 1 FROM attempts WHERE user_id = :u AND shift_id IS NOT NULL LIMIT 1")
                .param("u", user.id()).query(Integer.class).optional().isPresent();
        long xp = jdbc.sql("SELECT coalesce(sum(points), 0) / 5 FROM attempts WHERE user_id = :u").param("u", user.id()).query(Long.class).single();
        int level = 1 + (int) (xp / 300);
        long seed = user.id().getMostSignificantBits() ^ date.toEpochDay() ^ (31L * round);
        String forced = catalog.forcedDifficulty(user.orgId()).orElse(null);
        return ShiftPlanner.plan(catalog.pool(user.locale(), user.orgId()), seen, first, "simple".equals(user.mode()), level, seed, forced);
    }

    @Transactional
    ActionResult act(UUID userId, UUID shiftId, String scenarioId, String action, long ms) {
        ShiftRow row = jdbc.sql("SELECT id, user_id, scenarios, completed, score, correct, round FROM daily_shifts WHERE id = :id AND user_id = :u")
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

    /** Practice modes are not limited: base learning stays free. */
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

    /** A swipe deck. Decks are unlimited; the cards a player saw longest ago come first. */
    @Transactional(readOnly = true)
    List<PublicScenario> swipeDeck(UUID userId) {
        UserRef user = identity.require(userId);
        List<Scenario> pool = catalog.pool(user.locale(), user.orgId()).stream()
                .filter(s -> !s.type().equals("call") && !s.type().equals("scene")).toList();
        return batch(user, pool, null, SWIPE_DECK_SIZE);
    }

    /** The next questions of the endless mode. This never runs dry. */
    @Transactional(readOnly = true)
    List<PublicScenario> endless(UUID userId, String difficulty) {
        UserRef user = identity.require(userId);
        return batch(user, catalog.pool(user.locale(), user.orgId()), difficulty, ENDLESS_BATCH);
    }

    private List<PublicScenario> batch(UserRef user, List<Scenario> pool, String difficulty, int count) {
        // A level pinned by the manager outranks the player's own choice.
        String level = catalog.forcedDifficulty(user.orgId()).orElse(difficulty);
        Map<String, Long> lastSeen = new HashMap<>();
        jdbc.sql("SELECT scenario_id, max(created_at) AS at FROM attempts WHERE user_id = :u GROUP BY scenario_id").param("u", user.id())
                .query(rs -> {
                    lastSeen.put(rs.getString("scenario_id"), rs.getTimestamp("at").getTime());
                });
        List<String> ids = ShiftPlanner.endless(pool, lastSeen, level, "simple".equals(user.mode()), count, new Random().nextLong());
        return ids.stream().map(id -> catalog.find(id, user.locale())).flatMap(java.util.Optional::stream).map(Scenario::toPublic).toList();
    }

    @Transactional(readOnly = true)
    List<PublicScenario> flagsDeck(UUID userId) {
        UserRef user = identity.require(userId);
        List<Scenario> pool = new ArrayList<>(catalog.pool(user.locale(), user.orgId()).stream()
                .filter(s -> s.type().equals("email") && s.attack() && s.redFlags().size() >= 2).toList());
        String forced = catalog.forcedDifficulty(user.orgId()).orElse(null);
        if (forced != null && pool.stream().anyMatch(s -> s.fitsDifficulty(forced))) {
            pool.removeIf(s -> !s.fitsDifficulty(forced));
        }
        Collections.shuffle(pool, new Random());
        return pool.stream().limit(5).map(Scenario::toPublic).toList();
    }

    /** A lesson continues where the player left off: what is solved stays solved. A finished module can be replayed in full. */
    @Transactional(readOnly = true)
    List<PublicScenario> moduleLesson(UUID userId, int module) {
        UserRef user = identity.require(userId);
        List<Scenario> all = catalog.pool(user.locale(), user.orgId()).stream()
                .filter(s -> s.module() == module)
                .sorted((a, b) -> Integer.compare(ShiftPlanner.difficultyRank(a.difficulty()), ShiftPlanner.difficultyRank(b.difficulty())))
                .toList();
        Set<String> solved = solvedBy(userId);
        List<Scenario> open = all.stream().filter(s -> !solved.contains(s.id())).toList();
        return (open.isEmpty() ? all : open).stream().map(Scenario::toPublic).toList();
    }

    private Set<String> solvedBy(UUID userId) {
        return new HashSet<>(jdbc.sql("SELECT DISTINCT scenario_id FROM attempts WHERE user_id = :u AND is_correct")
                .param("u", userId).query(String.class).list());
    }

    @Override
    @Transactional(readOnly = true)
    public Energy energy(UUID userId) {
        ShiftRow row = findShift(userId, LocalDate.now(clock));
        return new Energy(row != null && row.completed, row == null ? 0 : row.round);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<Integer, Integer> moduleProgress(UUID userId) {
        UserRef user = identity.require(userId);
        Set<String> solved = solvedBy(userId);
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
    public Map<Integer, Integer> moduleTotals(UUID userId) {
        UserRef user = identity.require(userId);
        Map<Integer, Integer> out = new TreeMap<>();
        catalog.pool(user.locale(), user.orgId()).forEach(s -> out.merge(s.module(), 1, Integer::sum));
        return out;
    }

    @Override
    @Transactional(readOnly = true)
    public java.util.Optional<String> forcedDifficulty(UUID userId) {
        return catalog.forcedDifficulty(identity.require(userId).orgId());
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
        return jdbc.sql("SELECT id, user_id, scenarios, completed, score, correct, round FROM daily_shifts WHERE user_id = :u AND date = :d ORDER BY round DESC LIMIT 1")
                .param("u", userId).param("d", Date.valueOf(date)).query(ShiftService::mapShift).optional().orElse(null);
    }

    private List<String> answeredIn(UUID shiftId) {
        return jdbc.sql("SELECT scenario_id FROM attempts WHERE shift_id = :id").param("id", shiftId).query(String.class).list();
    }

    private static ShiftRow mapShift(java.sql.ResultSet rs, int n) throws java.sql.SQLException {
        String joined = rs.getString("scenarios");
        List<String> ids = joined.isEmpty() ? List.of() : Arrays.asList(joined.split(","));
        return new ShiftRow(rs.getObject("id", UUID.class), ids, rs.getBoolean("completed"), rs.getInt("score"), rs.getInt("round"));
    }

    private record ShiftRow(UUID id, List<String> scenarios, boolean completed, int score, int round) {
    }
}
