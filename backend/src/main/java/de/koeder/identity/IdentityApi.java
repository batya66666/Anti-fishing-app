package de.koeder.identity;

import java.util.Collection;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/** What other modules may know about a user. */
public interface IdentityApi {

    UserRef require(UUID userId);

    Map<UUID, UserRef> find(Collection<UUID> userIds);

    /** Creates a manager account for the demo company, or returns the existing one. */
    UUID ensureManager(String email, String password, String displayName, UUID orgId);

    void assignOrg(UUID userId, UUID orgId);

    Optional<UUID> orgOf(UUID userId);

    void updateSettings(UUID userId, SettingsChange change);

    void deleteAccount(UUID userId);

    record SettingsChange(String displayName, Integer avatar, String locale, String mode, Boolean publicBoard) {
    }
}
