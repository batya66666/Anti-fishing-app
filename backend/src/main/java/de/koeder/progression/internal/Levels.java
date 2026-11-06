package de.koeder.progression.internal;

/** Levels are job titles: the career from intern to CISO is the long-term motivation. */
final class Levels {

    /** XP required to reach each level. Index 0 is level 1. */
    static final int[] THRESHOLDS = {0, 150, 400, 800, 1400, 2200, 3200, 4500};
    static final String[] TITLES = {"Praktikant", "Junior", "Sachbearbeiter", "Senior", "Teamleiter", "Abteilungsleiter", "Security Lead", "CISO"};

    private Levels() {
    }

    static int levelFor(int xp) {
        int level = 1;
        for (int i = 0; i < THRESHOLDS.length; i++) {
            if (xp >= THRESHOLDS[i]) {
                level = i + 1;
            }
        }
        return level;
    }

    static String title(int level) {
        return TITLES[Math.clamp(level, 1, TITLES.length) - 1];
    }

    static int nextThreshold(int level) {
        return level >= THRESHOLDS.length ? THRESHOLDS[THRESHOLDS.length - 1] : THRESHOLDS[level];
    }

    static int currentThreshold(int level) {
        return THRESHOLDS[Math.clamp(level, 1, THRESHOLDS.length) - 1];
    }
}
