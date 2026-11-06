package de.koeder.shift;

import java.util.UUID;

/** One answered scenario, in any mode. progression turns it into XP, organization into statistics. */
public record ScenarioAnswered(UUID userId, String scenarioId, String context, String bucket, boolean attack, String outcome,
                               boolean correct, boolean reported, int xp, int coins) {
}
