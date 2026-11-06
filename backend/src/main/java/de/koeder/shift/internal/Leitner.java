package de.koeder.shift.internal;

import java.time.Duration;
import java.util.Optional;

/** Spaced repetition: mistakes return after 1, 3, 7, 14, 30 days. A new mistake restarts at day 1. */
final class Leitner {

    static final int[] INTERVAL_DAYS = {1, 3, 7, 14, 30};
    static final int LAST_BOX = INTERVAL_DAYS.length;

    private Leitner() {
    }

    /** Next box after an answer, or empty if the scenario has graduated and leaves the queue. */
    static Optional<Integer> nextBox(int box, boolean correct) {
        if (!correct) {
            return Optional.of(1);
        }
        return box >= LAST_BOX ? Optional.empty() : Optional.of(box + 1);
    }

    static Duration interval(int box) {
        return Duration.ofDays(INTERVAL_DAYS[Math.clamp(box, 1, LAST_BOX) - 1]);
    }
}
