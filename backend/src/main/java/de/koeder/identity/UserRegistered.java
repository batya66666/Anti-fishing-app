package de.koeder.identity;

import java.util.UUID;

/** Published when a new guest appears. Listeners run inside the registering transaction. */
public record UserRegistered(UUID userId) {
}
