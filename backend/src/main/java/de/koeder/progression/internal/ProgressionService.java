package de.koeder.progression.internal;

import java.sql.Date;
import java.time.Clock;
import java.time.LocalDate;
import java.time.temporal.IsoFields;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.event.EventListener;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import de.koeder.duel.DuelFinished;
import de.koeder.identity.UserRegistered;
import de.koeder.shift.ScenarioAnswered;
import de.koeder.shift.ShiftCompleted;

/**
 * Turns domain events into XP, streaks, leagues and badges.
 * The listeners are synchronous on purpose: they run inside the answering transaction,
 * so the /api/me call right after the last answer of a shift already shows the new level.
 */
@Service
class ProgressionService {

    private final JdbcClient jdbc;
    private final Clock clock;

    ProgressionService(JdbcClient jdbc, Clock clock) {
        this.jdbc = jdbc;
        this.clock = clock;
    }

    @EventListener
    @Transactional
    public void on(UserRegistered e) {
        ensure(e.userId());
    }

    @EventListener
    @Transactional
    public void on(ScenarioAnswered e) {
        ensure(e.userId());
        jdbc.sql("""
                UPDATE player_progress SET xp = xp + :xp, coins = coins + :coins,
                  attacks_seen = attacks_seen + :attack, attacks_reported = attacks_reported + :reported,
                  times_hacked = times_hacked + :hacked, false_alarms = false_alarms + :fa,
                  answers = answers + 1, answers_correct = answers_correct + :correct
                WHERE user_id = :u
                """)
                .param("xp", e.xp()).param("coins", e.coins()).param("attack", e.attack() ? 1 : 0)
                .param("reported", e.reported() ? 1 : 0).param("hacked", "HACKED".equals(e.outcome()) ? 1 : 0)
                .param("fa", "FALSE_ALARM".equals(e.outcome()) ? 1 : 0).param("correct", e.correct() ? 1 : 0)
                .param("u", e.userId()).update();
        addWeeklyXp(e.userId(), e.xp());
        touchStreak(e.userId());
        awardBadges(e.userId(), e);
    }

    @EventListener
    @Transactional
    public void on(ShiftCompleted e) {
        ensure(e.userId());
        int bonus = 30 + (e.correct() == e.total() ? 30 : 0);
        jdbc.sql("UPDATE player_progress SET shifts_done = shifts_done + 1, xp = xp + :b, coins = coins + 10 WHERE user_id = :u")
                .param("b", bonus).param("u", e.userId()).update();
        addWeeklyXp(e.userId(), bonus);
        award(e.userId(), "first_shift");
        if (e.correct() == e.total()) {
            award(e.userId(), "perfect_shift");
        }
    }

    @EventListener
    @Transactional
    public void on(DuelFinished e) {
        for (var p : e.players()) {
            ensure(p.userId());
            int xp = p.won() ? 40 : 15;
            jdbc.sql("UPDATE player_progress SET xp = xp + :xp, coins = coins + :c WHERE user_id = :u")
                    .param("xp", xp).param("c", p.won() ? 10 : 2).param("u", p.userId()).update();
            addWeeklyXp(p.userId(), xp);
            touchStreak(p.userId());
            award(p.userId(), "first_duel");
            if (p.won()) {
                award(p.userId(), "duel_winner");
            }
        }
    }

    /** Pure streak rule, tested directly: returns the new streak and how many freezes are consumed. */
    static StreakChange nextStreak(LocalDate last, LocalDate today, int streak, int freezes) {
        if (last == null) {
            return new StreakChange(1, 0);
        }
        long gap = today.toEpochDay() - last.toEpochDay();
        if (gap <= 0) {
            return new StreakChange(Math.max(streak, 1), 0);
        }
        if (gap == 1) {
            return new StreakChange(streak + 1, 0);
        }
        // One missed day can be covered by a freeze. A longer gap starts over: no guilt, just day one.
        if (gap == 2 && freezes > 0) {
            return new StreakChange(streak + 1, 1);
        }
        return new StreakChange(1, 0);
    }

    record StreakChange(int streak, int freezesUsed) {
    }

    private void touchStreak(UUID userId) {
        LocalDate today = LocalDate.now(clock);
        var row = jdbc.sql("SELECT last_active, streak, streak_freezes FROM player_progress WHERE user_id = :u")
                .param("u", userId)
                .query((rs, n) -> new Object[]{rs.getDate(1) == null ? null : rs.getDate(1).toLocalDate(), rs.getInt(2), rs.getInt(3)})
                .single();
        StreakChange change = nextStreak((LocalDate) row[0], today, (int) row[1], (int) row[2]);
        jdbc.sql("""
                UPDATE player_progress SET last_active = :d, streak = :s, best_streak = greatest(best_streak, :s),
                  streak_freezes = streak_freezes - :f WHERE user_id = :u
                """).param("d", Date.valueOf(today)).param("s", change.streak()).param("f", change.freezesUsed()).param("u", userId).update();
        if (change.streak() >= 3) {
            award(userId, "streak_3");
        }
        if (change.streak() >= 7) {
            award(userId, "streak_7");
        }
    }

    private void awardBadges(UUID userId, ScenarioAnswered e) {
        if (e.reported()) {
            award(userId, "first_report");
            int reports = jdbc.sql("SELECT attacks_reported FROM player_progress WHERE user_id = :u").param("u", userId).query(Integer.class).single();
            if (reports >= 25) {
                award(userId, "reporter_25");
            }
        }
        if (e.correct() && e.attack()) {
            switch (e.bucket()) {
                case "ceo_fraud" -> award(userId, "ceo_proof");
                case "mfa_fatigue" -> award(userId, "mfa_iron");
                case "malicious_attachment", "macro" -> award(userId, "macro_hunter");
                case "homoglyph", "lookalike_domain" -> award(userId, "homoglyph_eye");
                case "quishing" -> award(userId, "qr_sceptic");
                default -> {
                }
            }
        }
        if ("HACKED".equals(e.outcome())) {
            award(userId, "learned_the_hard_way");
        }
    }

    private void award(UUID userId, String badge) {
        jdbc.sql("INSERT INTO user_badges (user_id, badge) VALUES (:u, :b) ON CONFLICT DO NOTHING").param("u", userId).param("b", badge).update();
    }

    private void addWeeklyXp(UUID userId, int xp) {
        String week = currentWeek();
        jdbc.sql("""
                INSERT INTO league_members (user_id, week, tier, weekly_xp) VALUES (:u, :w, :t, :x)
                ON CONFLICT (user_id, week) DO UPDATE SET weekly_xp = league_members.weekly_xp + :x
                """).param("u", userId).param("w", week).param("t", tierFor(userId)).param("x", xp).update();
    }

    /** A player keeps the tier of their most recent league week. Promotion happens in the weekly reset. */
    private String tierFor(UUID userId) {
        return jdbc.sql("SELECT tier FROM league_members WHERE user_id = :u ORDER BY week DESC LIMIT 1")
                .param("u", userId).query(String.class).optional().orElse("bronze");
    }

    private void ensure(UUID userId) {
        jdbc.sql("INSERT INTO player_progress (user_id) VALUES (:u) ON CONFLICT DO NOTHING").param("u", userId).update();
    }

    String currentWeek() {
        LocalDate now = LocalDate.now(clock);
        return now.get(IsoFields.WEEK_BASED_YEAR) + "-W" + String.format("%02d", now.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR));
    }

    /** Sunday night: the top 7 of each tier move up, the next week starts at zero XP. */
    @org.springframework.scheduling.annotation.Scheduled(cron = "0 55 23 * * SUN", zone = "Europe/Berlin")
    @Transactional
    public void rollLeagues() {
        String week = currentWeek();
        String next = LocalDate.now(clock).plusWeeks(1).get(IsoFields.WEEK_BASED_YEAR) + "-W"
                + String.format("%02d", LocalDate.now(clock).plusWeeks(1).get(IsoFields.WEEK_OF_WEEK_BASED_YEAR));
        List<String> tiers = List.of("bronze", "silver", "gold", "diamond");
        for (int i = 0; i < tiers.size(); i++) {
            String tier = tiers.get(i);
            String up = tiers.get(Math.min(i + 1, tiers.size() - 1));
            jdbc.sql("""
                    INSERT INTO league_members (user_id, week, tier, weekly_xp)
                    SELECT user_id, :next, CASE WHEN rn <= 7 THEN :up ELSE :tier END, 0
                    FROM (SELECT user_id, row_number() OVER (ORDER BY weekly_xp DESC) rn FROM league_members WHERE week = :w AND tier = :tier) t
                    ON CONFLICT DO NOTHING
                    """).param("next", next).param("up", up).param("tier", tier).param("w", week).update();
        }
    }

    @Cacheable(cacheNames = "leaderboard", key = "#scope + ':' + #orgId")
    @Transactional(readOnly = true)
    public List<BoardRow> leaderboard(String scope, UUID orgId) {
        String sql = switch (scope) {
            case "org" -> """
                    SELECT pr.id, pr.display_name, pr.avatar, p.xp, coalesce(d.elo, 1000) elo, p.streak
                    FROM player_progress p JOIN profiles pr ON pr.id = p.user_id LEFT JOIN duel_ratings d ON d.user_id = p.user_id
                    WHERE pr.org_id = :org AND p.xp > 0 ORDER BY p.xp DESC LIMIT 50
                    """;
            case "league" -> """
                    SELECT pr.id, pr.display_name, pr.avatar, l.weekly_xp xp, coalesce(d.elo, 1000) elo, coalesce(p.streak, 0) streak
                    FROM league_members l JOIN profiles pr ON pr.id = l.user_id
                    LEFT JOIN duel_ratings d ON d.user_id = l.user_id LEFT JOIN player_progress p ON p.user_id = l.user_id
                    WHERE l.week = :week AND pr.public_board ORDER BY l.weekly_xp DESC LIMIT 30
                    """;
            default -> """
                    SELECT pr.id, pr.display_name, pr.avatar, p.xp, coalesce(d.elo, 1000) elo, p.streak
                    FROM player_progress p JOIN profiles pr ON pr.id = p.user_id LEFT JOIN duel_ratings d ON d.user_id = p.user_id
                    WHERE pr.public_board AND p.xp > 0 ORDER BY p.xp DESC LIMIT 50
                    """;
        };
        var spec = jdbc.sql(sql);
        if (sql.contains(":org")) {
            spec = spec.param("org", orgId, java.sql.Types.OTHER);
        }
        if (sql.contains(":week")) {
            spec = spec.param("week", currentWeek());
        }
        List<BoardRow> rows = new ArrayList<>();
        int[] rank = {0};
        spec.query((rs, n) -> new BoardRow(++rank[0], rs.getObject("id", UUID.class), rs.getString("display_name"), rs.getInt("avatar"),
                rs.getInt("xp"), rs.getInt("elo"), rs.getInt("streak"), Levels.levelFor(rs.getInt("xp")))).list().forEach(rows::add);
        return rows;
    }

    record BoardRow(int rank, UUID userId, String name, int avatar, int xp, int elo, int streak, int level) {
    }

    @Transactional
    public Map<String, Object> progressRow(UUID userId) {
        ensure(userId);
        return jdbc.sql("SELECT * FROM player_progress WHERE user_id = :u").param("u", userId).query().singleRow();
    }

    @Transactional(readOnly = true)
    public List<String> badges(UUID userId) {
        return jdbc.sql("SELECT badge FROM user_badges WHERE user_id = :u ORDER BY earned_at").param("u", userId).query(String.class).list();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> league(UUID userId) {
        var row = jdbc.sql("SELECT tier, weekly_xp FROM league_members WHERE user_id = :u AND week = :w")
                .param("u", userId).param("w", currentWeek()).query().listOfRows();
        return row.isEmpty() ? Map.of("tier", tierFor(userId), "weekly_xp", 0) : row.get(0);
    }
}
