package de.koeder.content;

import java.util.Collection;
import java.util.List;
import java.util.Set;

import de.koeder.content.Evaluation.Outcome;

/**
 * Scoring rules, free of Spring so they can be unit-tested directly.
 * The rules teach the main metric of the product: reporting beats merely not clicking.
 */
public final class ScenarioEvaluator {

    static final int REPORT_POINTS = 100;
    static final int LEGIT_POINTS = 80;
    static final int SAFE_POINTS = 60;
    static final int FALSE_ALARM_POINTS = 10;
    static final int MISSED_POINTS = 20;
    static final int MAX_SPEED_BONUS = 30;
    static final long SPEED_WINDOW_MS = 20_000;
    private static final Set<String> SUSPICION_ACTIONS = Set.of("report", "delete");

    private ScenarioEvaluator() {
    }

    /** Evaluates what the player did with a message in a shift, review or module lesson. */
    public static Evaluation evaluateAction(Scenario s, String action, long ms) {
        List<String> correct = s.correctActions();
        Outcome outcome;
        int points;
        if (s.dangerousActions() != null && s.dangerousActions().contains(action)) {
            outcome = Outcome.HACKED;
            points = 0;
        } else if (!correct.isEmpty() && correct.get(0).equals(action)) {
            outcome = Outcome.CORRECT;
            points = (s.attack() ? REPORT_POINTS : LEGIT_POINTS) + speedBonus(ms);
        } else if (correct.contains(action)) {
            outcome = Outcome.SAFE;
            points = SAFE_POINTS;
        } else if (!s.attack() && SUSPICION_ACTIONS.contains(action)) {
            outcome = Outcome.FALSE_ALARM;
            points = FALSE_ALARM_POINTS;
        } else {
            outcome = Outcome.MISSED;
            points = MISSED_POINTS;
        }
        boolean ok = outcome == Outcome.CORRECT || outcome == Outcome.SAFE;
        boolean reported = s.attack() && "report".equals(action);
        return build(s, outcome, ok, reported, points, 0, 0, 0);
    }

    /** Swipe mode: one binary decision. verdict is "attack" or "legit". */
    public static Evaluation evaluateVerdict(Scenario s, String verdict, long ms) {
        boolean said = "attack".equals(verdict);
        boolean ok = said == s.attack();
        Outcome outcome = ok ? Outcome.CORRECT : (s.attack() ? Outcome.HACKED : Outcome.FALSE_ALARM);
        return build(s, outcome, ok, s.attack() && said, ok ? 50 + speedBonus(ms) : 0, 0, 0, 0);
    }

    /** Spot-the-flags mode. A tap on a body sentence counts if it contains the flagged phrase. */
    public static Evaluation evaluateFlags(Scenario s, Collection<String> tapped) {
        int found = 0;
        for (var flag : s.redFlags()) {
            if (tapped.stream().anyMatch(t -> matches(flag.target(), t))) {
                found++;
            }
        }
        int wrong = 0;
        for (String t : tapped) {
            if (s.redFlags().stream().noneMatch(f -> matches(f.target(), t))) {
                wrong++;
            }
        }
        int total = s.redFlags().size();
        int points = Math.max(0, found * 40 - wrong * 15);
        // A clean message has nothing to find: not tapping anything is the correct answer.
        boolean ok = total == 0 ? wrong == 0 : found * 2 >= total && wrong <= found;
        if (total == 0 && wrong == 0) {
            points = 80;
        }
        Outcome outcome = ok ? Outcome.CORRECT : Outcome.MISSED;
        return build(s, outcome, ok, false, points, found, total - found, wrong);
    }

    public static boolean matches(String flagTarget, String tapped) {
        if (flagTarget.startsWith("body:") && tapped.startsWith("body:")) {
            return tapped.toLowerCase().contains(flagTarget.substring(5).toLowerCase());
        }
        return flagTarget.equals(tapped);
    }

    static int speedBonus(long ms) {
        long clamped = Math.clamp(ms, 0L, SPEED_WINDOW_MS);
        return (int) Math.round(MAX_SPEED_BONUS * (1.0 - (double) clamped / SPEED_WINDOW_MS));
    }

    private static Evaluation build(Scenario s, Outcome outcome, boolean ok, boolean reported, int points, int found, int missed, int wrong) {
        int xp = Math.max(1, points / 5);
        int coins = outcome == Outcome.CORRECT ? 5 : (outcome == Outcome.SAFE ? 2 : 0);
        return new Evaluation(outcome, ok, s.attack(), reported, points, xp, coins, found, missed, wrong,
                s.redFlags(), s.statsBucket(), s.explanation());
    }
}
