package de.koeder.identity.internal;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

interface ProfileRepository extends JpaRepository<Profile, UUID> {

    Optional<Profile> findByDeviceId(String deviceId);

    Optional<Profile> findByEmail(String email);
}
