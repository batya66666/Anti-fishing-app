package de.koeder.identity;

import java.util.UUID;

public record UserRef(UUID id, String displayName, int avatar, String locale, String mode, String role, UUID orgId,
                      boolean publicBoard, String email) {
}
