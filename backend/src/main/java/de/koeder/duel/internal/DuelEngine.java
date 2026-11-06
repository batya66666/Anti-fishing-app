package de.koeder.duel.internal;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.server.ResponseStatusException;

import de.koeder.content.Scenario;
import de.koeder.content.ScenarioCatalog;
import de.koeder.content.ScenarioEvaluator;
import de.koeder.duel.DuelApi;
import de.koeder.duel.DuelFinished;
import de.koeder.duel.internal.DuelState.Answer;
import de.koeder.duel.internal.DuelState.Phase;
import de.koeder.duel.internal.DuelState.Round;
import de.koeder.duel.internal.DuelState.Seat;
import de.koeder.identity.IdentityApi;
import de.koeder.identity.UserRef;

/**
 * Runs matches. The server owns everything that decides a duel: it picks the scenarios,
 * never sends the solution before a round ends, and measures response time on its own clock.
 */
@Service
class DuelEngine implements DuelApi {

    private static final Logger log = LoggerFactory.getLogger(DuelEngine.class);
    private static final int ROUNDS = 5;
    private static final List<String> BOT_NAMES = List.of("Bot Otto", "Bot Grete", "Bot Kalle", "Bot Frieda");

    private final Map<UUID, DuelState> active = new ConcurrentHashMap<>();
    private final SimpMessagingTemplate broker;
    private final TaskScheduler scheduler;
    private final ScenarioCatalog catalog;
    private final IdentityApi identity;
    private final JdbcClient jdbc;
    private final TransactionTemplate tx;
    private final ApplicationEventPublisher events;
    private final Clock clock;
    private final int roundSeconds;
    private final long countdownMs;
    private final long resultPauseMs;

    DuelEngine(SimpMessagingTemplate broker, TaskScheduler scheduler, ScenarioCatalog catalog, IdentityApi identity,
               JdbcClient jdbc, TransactionTemplate tx, ApplicationEventPublisher events, Clock clock,
               @Value("${koeder.duel.round-seconds}") int roundSeconds,
               @Value("${koeder.duel.countdown-ms}") long countdownMs,
               @Value("${koeder.duel.result-pause-ms}") long resultPauseMs) {
        this.broker = broker;
        this.scheduler = scheduler;
        this.catalog = catalog;
        this.identity = identity;
        this.jdbc = jdbc;
        this.tx = tx;
        this.events = events;
        this.clock = clock;
        this.roundSeconds = roundSeconds;
        this.countdownMs = countdownMs;
        this.resultPauseMs = resultPauseMs;
    }

    // ------------------------------------------------------------------ creating matches

    DuelState create(UUID playerA, UUID playerB, String mode) {
        long seed = ThreadLocalRandom.current().nextLong();
        UserRef ua = identity.require(playerA);
        Seat a = humanSeat("a", ua);
        Seat b;
        String locale2;
        if (playerB == null) {
            // Bot strength follows the player, so a beginner can win and a veteran cannot farm.
            double accuracy = Math.clamp(0.6 + (a.elo - 1000) / 1000.0, 0.6, 0.9);
            String name = BOT_NAMES.get(ThreadLocalRandom.current().nextInt(BOT_NAMES.size()));
            b = new Seat("b", null, name, ThreadLocalRandom.current().nextInt(8), a.elo + ThreadLocalRandom.current().nextInt(-40, 41), 99, ua.locale(), accuracy);
            locale2 = ua.locale();
        } else {
            UserRef ub = identity.require(playerB);
            b = humanSeat("b", ub);
            locale2 = ub.locale();
        }
        List<Round> rounds = pickRounds(seed, ua.locale(), locale2);
        UUID id = UUID.randomUUID();
        DuelState duel = new DuelState(id, mode, seed, a, b, rounds);
        active.put(id, duel);
        persistStart(duel);
        // A player who never shows up must not block the other one.
        scheduler.schedule(() -> forceStart(id), clock.instant().plusSeconds(10));
        return duel;
    }

    private Seat humanSeat(String key, UserRef u) {
        Rating r = rating(u.id());
        return new Seat(key, u.id(), u.displayName(), u.avatar(), r.elo(), r.wins() + r.losses() + r.draws(), u.locale(), 0);
    }

    /** Same seed, same scenarios for both players. Each player reads them in their own language. */
    private List<Round> pickRounds(long seed, String localeA, String localeB) {
        Random random = new Random(seed);
        List<Scenario> pool = new ArrayList<>(catalog.pool(localeA, null));
        Collections.shuffle(pool, random);
        List<String> kinds = List.of("swipe", "swipe", "url", "flags", "swipe");
        List<Round> rounds = new ArrayList<>();
        List<String> used = new ArrayList<>();
        for (int i = 0; i < ROUNDS; i++) {
            String kind = kinds.get(i);
            Scenario pick = pool.stream().filter(s -> !used.contains(s.id())).filter(s -> fits(s, kind)).findFirst()
                    .orElseGet(() -> pool.stream().filter(s -> !used.contains(s.id())).filter(s -> fits(s, "swipe")).findFirst().orElseThrow());
            used.add(pick.id());
            Map<String, Scenario> byLocale = new LinkedHashMap<>();
            byLocale.put(pick.locale(), pick);
            if (!localeB.equals(localeA)) {
                catalog.find(pick.id(), localeB).ifPresent(s -> byLocale.put(s.locale(), s));
            }
            rounds.add(new Round(i + 1, fits(pick, kind) ? kind : "swipe", byLocale));
        }
        return rounds;
    }

    private static boolean fits(Scenario s, String kind) {
        return switch (kind) {
            case "url" -> s.type().equals("url");
            case "flags" -> s.type().equals("email") && s.attack() && s.redFlags().size() >= 2;
            default -> List.of("email", "sms", "chat", "qr", "push", "file").contains(s.type());
        };
    }

    Optional<DuelState> find(UUID id) {
        return Optional.ofNullable(active.get(id));
    }

    // ------------------------------------------------------------------ lifecycle

    void ready(UUID duelId, UUID userId) {
        withDuel(duelId, d -> {
            Seat seat = d.seat(userId);
            if (seat == null) {
                return; // spectators only listen
            }
            seat.ready = true;
            sendSnapshot(d);
            if (d.phase == Phase.WAITING && (d.b.isBot() || (d.a.ready && d.b.ready))) {
                startCountdown(d);
            }
        });
    }

    private void forceStart(UUID duelId) {
        withDuel(duelId, d -> {
            if (d.phase == Phase.WAITING) {
                startCountdown(d);
            }
        });
    }

    private void startCountdown(DuelState d) {
        d.phase = Phase.COUNTDOWN;
        publish(d, Map.of("type", "countdown", "ms", countdownMs));
        scheduler.schedule(() -> withDuel(d.id, this::nextRound), clock.instant().plusMillis(countdownMs));
    }

    private void nextRound(DuelState d) {
        if (d.phase == Phase.FINISHED) {
            return;
        }
        d.current++;
        if (d.current >= d.rounds.size()) {
            finish(d);
            return;
        }
        d.phase = Phase.ROUND;
        d.roundStartedAt = clock.instant();
        publish(d, roundMessage(d));
        int no = d.current;
        scheduler.schedule(() -> withDuel(d.id, x -> {
            if (x.phase == Phase.ROUND && x.current == no) {
                closeRound(x);
            }
        }), d.roundStartedAt.plusSeconds(roundSeconds));
        if (d.b.isBot()) {
            scheduleBot(d, no);
        }
    }

    private Map<String, Object> roundMessage(DuelState d) {
        Round r = d.round();
        Map<String, Object> scenarios = new HashMap<>();
        // Only the public view goes out: no verdict, no flags, no explanation.
        r.byLocale.forEach((locale, s) -> scenarios.put(locale, s.toPublic()));
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "round");
        m.put("no", r.no);
        m.put("total", d.rounds.size());
        m.put("kind", r.kind);
        m.put("seconds", roundSeconds);
        m.put("scenarios", scenarios);
        return m;
    }

    void answer(UUID duelId, UUID userId, int roundNo, String verdict, List<String> flags) {
        withDuel(duelId, d -> {
            Seat seat = d.seat(userId);
            if (seat == null || d.phase != Phase.ROUND || d.round().no != roundNo) {
                return; // late or foreign answers simply do not count
            }
            long ms = Duration.between(d.roundStartedAt, clock.instant()).toMillis();
            applyAnswer(d, seat, verdict, flags, ms);
        });
    }

    private void applyAnswer(DuelState d, Seat seat, String verdict, List<String> flags, long ms) {
        Round r = d.round();
        if ("a".equals(seat.key) ? r.answerA != null : r.answerB != null) {
            return; // one answer per round
        }
        Answer answer = score(r, verdict, flags, ms);
        if ("a".equals(seat.key)) {
            r.answerA = answer;
        } else {
            r.answerB = answer;
        }
        // Tell the opponent THAT I answered, not whether I was right.
        publish(d, Map.of("type", "progress", "player", seat.key, "round", r.no, "ms", ms));
        if (r.bothAnswered()) {
            closeRound(d);
        }
    }

    private static Answer score(Round r, String verdict, List<String> flags, long ms) {
        Scenario s = r.canonical();
        if ("flags".equals(r.kind)) {
            List<String> tapped = flags == null ? List.of() : flags;
            // Flag targets are structural ("from_email", "link:0") or quote the body, so a player reading
            // another language is scored against that language's scenario by the caller's locale-free targets.
            var e = bestFlagEvaluation(r, tapped);
            int points = DuelScoring.flagPoints(e.flagsFound(), e.flagsWrong());
            return new Answer(null, tapped, ms, points, e.correct());
        }
        boolean correct = "attack".equals(verdict) == s.attack();
        return new Answer(verdict, null, ms, verdict == null ? 0 : DuelScoring.verdictPoints(correct, ms), verdict != null && correct);
    }

    private static de.koeder.content.Evaluation bestFlagEvaluation(Round r, List<String> tapped) {
        return r.byLocale.values().stream().map(s -> ScenarioEvaluator.evaluateFlags(s, tapped))
                .max((x, y) -> Integer.compare(x.flagsFound(), y.flagsFound())).orElseThrow();
    }

    private void closeRound(DuelState d) {
        Round r = d.round();
        if (r.answerA == null) {
            r.answerA = new Answer(null, null, roundSeconds * 1000L, 0, false);
        }
        if (r.answerB == null) {
            r.answerB = new Answer(null, null, roundSeconds * 1000L, 0, false);
        }
        d.a.score += r.answerA.points();
        d.b.score += r.answerB.points();
        d.a.correct += r.answerA.correct() ? 1 : 0;
        d.b.correct += r.answerB.correct() ? 1 : 0;
        d.a.perRound.add(r.answerA.points());
        d.b.perRound.add(r.answerB.points());
        d.phase = Phase.RESULT;

        Map<String, Object> solutions = new HashMap<>();
        r.byLocale.forEach((locale, s) -> solutions.put(locale, Map.of(
                "isAttack", s.attack(), "explanation", s.explanation(), "redFlags", s.redFlags())));
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "round_result");
        m.put("no", r.no);
        m.put("solutions", solutions);
        m.put("a", seatResult(d.a, r.answerA));
        m.put("b", seatResult(d.b, r.answerB));
        publish(d, m);
        // Schedule first: a database hiccup may lose a round record, but must not freeze the match.
        scheduler.schedule(() -> withDuel(d.id, this::nextRound), clock.instant().plusMillis(resultPauseMs));
        persistRound(d, r);
    }

    private static Map<String, Object> seatResult(Seat s, Answer a) {
        return Map.of("points", a.points(), "correct", a.correct(), "ms", a.ms(), "total", s.score);
    }

    private void finish(DuelState d) {
        d.phase = Phase.FINISHED;
        String winner = d.a.score == d.b.score ? null : (d.a.score > d.b.score ? "a" : "b");
        int deltaA = 0;
        int deltaB = 0;
        if (!"friendly".equals(d.mode)) {
            double scoreA = winner == null ? 0.5 : ("a".equals(winner) ? 1 : 0);
            deltaA = EloCalculator.delta(d.a.elo, d.b.elo, scoreA, d.a.games);
            deltaB = d.b.isBot() ? 0 : EloCalculator.delta(d.b.elo, d.a.elo, 1 - scoreA, d.b.games);
        }
        persistFinish(d, winner, deltaA, deltaB);

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "finished");
        if (winner != null) {
            m.put("winner", winner);
        }
        m.put("a", Map.of("score", d.a.score, "correct", d.a.correct, "eloDelta", deltaA, "elo", d.a.elo + deltaA, "perRound", d.a.perRound));
        m.put("b", Map.of("score", d.b.score, "correct", d.b.correct, "eloDelta", deltaB, "elo", d.b.elo + deltaB, "perRound", d.b.perRound));
        publish(d, m);
        // Keep the state around briefly: a reconnecting client can still fetch the final snapshot.
        scheduler.schedule(() -> active.remove(d.id), clock.instant().plus(Duration.ofMinutes(5)));
    }

    // ------------------------------------------------------------------ bot

    private void scheduleBot(DuelState d, int roundIndex) {
        var random = ThreadLocalRandom.current();
        long delay = random.nextLong(1800, Math.max(2000, (roundSeconds - 4) * 1000L));
        Instant at = clock.instant().plusMillis(delay);
        scheduler.schedule(() -> withDuel(d.id, x -> {
            if (x.phase != Phase.ROUND || x.current != roundIndex) {
                return;
            }
            Round r = x.round();
            boolean botRight = ThreadLocalRandom.current().nextDouble() < x.b.botAccuracy;
            long ms = Duration.between(x.roundStartedAt, clock.instant()).toMillis();
            if ("flags".equals(r.kind)) {
                List<String> targets = r.canonical().redFlags().stream().map(Scenario.RedFlag::target).toList();
                List<String> tapped = new ArrayList<>();
                for (String t : targets) {
                    if (ThreadLocalRandom.current().nextDouble() < x.b.botAccuracy) {
                        tapped.add(t);
                    }
                }
                applyAnswer(x, x.b, null, tapped, ms);
            } else {
                boolean attack = r.canonical().attack();
                applyAnswer(x, x.b, (attack == botRight) ? "attack" : "legit", null, ms);
            }
            if (ThreadLocalRandom.current().nextInt(4) == 0 && x.phase != Phase.FINISHED) {
                publish(x, Map.of("type", "reaction", "player", "b", "emoji", botRight ? "bolt" : "shock"));
            }
        }), at);
    }

    // ------------------------------------------------------------------ reactions, snapshots

    void react(UUID duelId, UUID userId, String emoji) {
        if (!List.of("fire", "bolt", "fish", "shock", "laugh", "shield").contains(emoji)) {
            return;
        }
        withDuel(duelId, d -> {
            Seat seat = d.seat(userId);
            if (seat != null) {
                publish(d, Map.of("type", "reaction", "player", seat.key, "emoji", emoji));
            }
        });
    }

    private void sendSnapshot(DuelState d) {
        publish(d, snapshot(d));
    }

    Map<String, Object> snapshot(DuelState d) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "state");
        m.put("id", d.id.toString());
        m.put("mode", d.mode);
        m.put("phase", d.phase.name());
        m.put("round", d.current + 1);
        m.put("total", d.rounds.size());
        m.put("a", seatInfo(d.a));
        m.put("b", seatInfo(d.b));
        return m;
    }

    private static Map<String, Object> seatInfo(Seat s) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("name", s.name);
        m.put("avatar", s.avatar);
        m.put("elo", s.elo);
        m.put("bot", s.isBot());
        m.put("ready", s.ready);
        m.put("score", s.score);
        if (s.userId != null) {
            m.put("userId", s.userId.toString());
        }
        return m;
    }

    private void publish(DuelState d, Map<String, ?> message) {
        broker.convertAndSend("/topic/duel/" + d.id, (Object) message);
    }

    private void withDuel(UUID id, java.util.function.Consumer<DuelState> action) {
        DuelState d = active.get(id);
        if (d == null) {
            return;
        }
        d.lock.lock();
        try {
            action.accept(d);
        } catch (RuntimeException e) {
            log.error("Duel {} failed", id, e);
        } finally {
            d.lock.unlock();
        }
    }

    /** Safety net: nothing that stopped ticking stays in memory forever. */
    @Scheduled(fixedDelay = 600_000)
    void sweep() {
        Instant cutoff = clock.instant().minus(Duration.ofHours(1));
        active.values().removeIf(d -> d.createdAt.isBefore(cutoff));
    }

    // ------------------------------------------------------------------ persistence

    @Override
    public Rating rating(UUID userId) {
        return jdbc.sql("SELECT elo, wins, losses, draws FROM duel_ratings WHERE user_id = :u").param("u", userId)
                .query((rs, n) -> new Rating(rs.getInt(1), rs.getInt(2), rs.getInt(3), rs.getInt(4)))
                .optional().orElse(new Rating(EloCalculator.START_RATING, 0, 0, 0));
    }

    private void persistStart(DuelState d) {
        jdbc.sql("INSERT INTO matches (id, mode, seed, status, player_a, player_b, bot_name) VALUES (:id, :m, :s, 'running', :a, :b, :bot)")
                .param("id", d.id).param("m", d.mode).param("s", d.seed)
                .param("a", d.a.userId, java.sql.Types.OTHER).param("b", d.b.userId, java.sql.Types.OTHER)
                .param("bot", d.b.isBot() ? d.b.name : null, java.sql.Types.VARCHAR).update();
    }

    private void persistRound(DuelState d, Round r) {
        jdbc.sql("""
                INSERT INTO match_rounds (match_id, round_no, scenario_id, kind, answer_a, answer_b, ms_a, ms_b, points_a, points_b)
                VALUES (:id, :no, :s, :k, :aa, :ab, :ma, :mb, :pa, :pb)
                """)
                .param("id", d.id).param("no", r.no).param("s", r.canonical().id()).param("k", r.kind)
                .param("aa", describe(r.answerA), java.sql.Types.VARCHAR).param("ab", describe(r.answerB), java.sql.Types.VARCHAR)
                .param("ma", (int) r.answerA.ms()).param("mb", (int) r.answerB.ms())
                .param("pa", r.answerA.points()).param("pb", r.answerB.points()).update();
    }

    private static String describe(Answer a) {
        return a.flags() != null ? String.join("|", a.flags()) : a.verdict();
    }

    private void persistFinish(DuelState d, String winner, int deltaA, int deltaB) {
        tx.executeWithoutResult(status -> {
            jdbc.sql("""
                    UPDATE matches SET status = 'finished', score_a = :sa, score_b = :sb, winner = :w,
                      elo_delta_a = :da, elo_delta_b = :db, finished_at = now() WHERE id = :id
                    """).param("sa", d.a.score).param("sb", d.b.score).param("w", winner, java.sql.Types.VARCHAR)
                    .param("da", deltaA).param("db", deltaB).param("id", d.id).update();
            List<DuelFinished.Player> players = new ArrayList<>();
            saveRating(d.a, deltaA, winner, players);
            if (!d.b.isBot()) {
                saveRating(d.b, deltaB, winner, players);
            }
            events.publishEvent(new DuelFinished(d.id, d.mode, players));
        });
    }

    private void saveRating(Seat s, int delta, String winner, List<DuelFinished.Player> players) {
        boolean won = s.key.equals(winner);
        boolean draw = winner == null;
        jdbc.sql("""
                INSERT INTO duel_ratings (user_id, elo, wins, losses, draws) VALUES (:u, :e, :w, :l, :dr)
                ON CONFLICT (user_id) DO UPDATE SET elo = duel_ratings.elo + :d,
                  wins = duel_ratings.wins + :w, losses = duel_ratings.losses + :l, draws = duel_ratings.draws + :dr
                """)
                .param("u", s.userId).param("e", EloCalculator.START_RATING + delta).param("d", delta)
                .param("w", won ? 1 : 0).param("l", !won && !draw ? 1 : 0).param("dr", draw ? 1 : 0).update();
        players.add(new DuelFinished.Player(s.userId, s.score, won, delta));
    }

    /** Throws 404 unless the duel is running and the caller is a player in it. */
    DuelState requireParticipant(UUID duelId, UUID userId) {
        DuelState d = active.get(duelId);
        if (d == null || !d.involves(userId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        return d;
    }
}
