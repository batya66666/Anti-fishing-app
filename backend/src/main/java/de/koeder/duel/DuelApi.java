package de.koeder.duel;

import java.util.UUID;

public interface DuelApi {

    Rating rating(UUID userId);

    record Rating(int elo, int wins, int losses, int draws) {
    }
}
