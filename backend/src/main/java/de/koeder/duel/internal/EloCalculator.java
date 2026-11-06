package de.koeder.duel.internal;

/** Standard ELO. K = 40 while a player is new, K = 32 afterwards. */
public final class EloCalculator {

    public static final int START_RATING = 1000;
    static final int K_NEW = 40;
    static final int K_DEFAULT = 32;
    static final int NEW_PLAYER_GAMES = 10;

    private EloCalculator() {
    }

    public static double expected(int ratingA, int ratingB) {
        return 1.0 / (1.0 + Math.pow(10.0, (ratingB - ratingA) / 400.0));
    }

    /** @param score 1 for a win, 0.5 for a draw, 0 for a loss */
    public static int delta(int rating, int opponent, double score, int gamesPlayed) {
        int k = gamesPlayed < NEW_PLAYER_GAMES ? K_NEW : K_DEFAULT;
        return (int) Math.round(k * (score - expected(rating, opponent)));
    }
}
