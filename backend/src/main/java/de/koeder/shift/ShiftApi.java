package de.koeder.shift;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/** Read model for the /api/me profile. */
public interface ShiftApi {

    Energy energy(UUID userId);

    /** Number of scenarios answered correctly at least once, per training module. */
    Map<Integer, Integer> moduleProgress(UUID userId);

    long reviewsDue(UUID userId);

    List<Map<String, Object>> exportAttempts(UUID userId);

    void demoReset(UUID userId);

    record Energy(boolean shiftAvailable, boolean shiftCompleted, int swipeRoundsLeft, int swipeRoundsPerDay) {
    }
}
