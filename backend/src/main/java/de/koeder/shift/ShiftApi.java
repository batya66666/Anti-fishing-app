package de.koeder.shift;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/** Read model for the /api/me profile. */
public interface ShiftApi {

    Energy energy(UUID userId);

    /** Number of scenarios answered correctly at least once, per training module. */
    Map<Integer, Integer> moduleProgress(UUID userId);

    /** How many scenarios each training module has for this user. */
    Map<Integer, Integer> moduleTotals(UUID userId);

    /** The difficulty pinned by this user's company, if any. */
    Optional<String> forcedDifficulty(UUID userId);

    long reviewsDue(UUID userId);

    List<Map<String, Object>> exportAttempts(UUID userId);

    void demoReset(UUID userId);

    record Energy(boolean shiftCompleted, int shiftsToday) {
    }
}
