package de.koeder.organization.internal;

/**
 * Human Risk Score, 0 (safe) to 100 (at risk): falling for attacks weighs most,
 * failing to report weighs next, and false alarms count a little so that "report everything" is not the optimum.
 */
final class RiskScore {

    /** Below this a number says nothing, so a group shows no score at all. */
    static final int MIN_ANSWERS = 5;

    private RiskScore() {
    }

    static Integer of(long answers, long attacks, long hacked, long reported, long falseAlarms) {
        if (answers < MIN_ANSWERS) {
            return null;
        }
        double clickRate = attacks == 0 ? 0 : (double) hacked / attacks;
        double missedReports = attacks == 0 ? 0 : 1.0 - (double) reported / attacks;
        long legit = answers - attacks;
        double falseRate = legit <= 0 ? 0 : (double) falseAlarms / legit;
        double raw = 100 * (0.6 * clickRate + 0.3 * missedReports + 0.1 * falseRate);
        return (int) Math.round(Math.clamp(raw, 0, 100));
    }

    static Double rate(long part, long whole) {
        return whole == 0 ? null : Math.round(1000.0 * part / whole) / 10.0;
    }
}
