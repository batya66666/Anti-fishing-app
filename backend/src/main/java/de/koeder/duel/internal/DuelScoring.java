package de.koeder.duel.internal;

/** Round score: 100 for a correct answer plus a speed bonus of up to 50, falling off linearly over 10 s. */
final class DuelScoring {

    static final int BASE = 100;
    static final int MAX_SPEED_BONUS = 50;
    static final long BONUS_WINDOW_MS = 10_000;
    static final int FLAG_POINTS = 50;
    static final int WRONG_FLAG_PENALTY = 25;
    static final int MAX_FLAG_ROUND = 150;

    private DuelScoring() {
    }

    static int verdictPoints(boolean correct, long ms) {
        if (!correct) {
            return 0;
        }
        long clamped = Math.clamp(ms, 0L, BONUS_WINDOW_MS);
        return BASE + (int) Math.round(MAX_SPEED_BONUS * (1.0 - (double) clamped / BONUS_WINDOW_MS));
    }

    static int flagPoints(int found, int wrong) {
        return Math.clamp(found * FLAG_POINTS - wrong * WRONG_FLAG_PENALTY, 0, MAX_FLAG_ROUND);
    }
}
