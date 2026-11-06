package de.koeder.identity.internal;

import java.time.Instant;
import java.util.UUID;

import de.koeder.identity.UserRef;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "profiles")
class Profile {

    @Id
    UUID id;
    @Column(name = "device_id")
    String deviceId;
    String email;
    @Column(name = "password_hash")
    String passwordHash;
    @Column(name = "display_name")
    String displayName;
    int avatar;
    String locale = "de";
    String mode = "standard";
    String role = "EMPLOYEE";
    @Column(name = "org_id")
    UUID orgId;
    @Column(name = "public_board")
    boolean publicBoard = true;
    @Column(name = "created_at")
    Instant createdAt = Instant.now();

    UserRef ref() {
        return new UserRef(id, displayName, avatar, locale, mode, role, orgId, publicBoard, email);
    }
}
