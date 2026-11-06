package de.koeder.duel;

import java.util.List;
import java.util.UUID;

/** Bots are not listed: only human players earn progress. */
public record DuelFinished(UUID duelId, String mode, List<Player> players) {

    public record Player(UUID userId, int score, boolean won, int eloDelta) {
    }
}
