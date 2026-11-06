package de.koeder.identity.internal;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import de.koeder.identity.IdentityApi;
import de.koeder.identity.UserRef;
import de.koeder.identity.UserRegistered;

@Service
class IdentityService implements IdentityApi {

    private static final List<String> NICK_A = List.of("Wachsamer", "Kluger", "Flinker", "Mutiger", "Stiller", "Cleverer", "Schneller", "Ruhiger");
    private static final List<String> NICK_B = List.of("Hecht", "Lachs", "Barsch", "Karpfen", "Zander", "Otter", "Fuchs", "Dachs");
    private static final Set<String> LOCALES = Set.of("de", "en");
    private static final Set<String> MODES = Set.of("standard", "simple");

    private final ProfileRepository profiles;
    private final PasswordEncoder encoder;
    private final ApplicationEventPublisher events;

    IdentityService(ProfileRepository profiles, PasswordEncoder encoder, ApplicationEventPublisher events) {
        this.profiles = profiles;
        this.encoder = encoder;
        this.events = events;
    }

    @Transactional
    Profile guest(String deviceId, String displayName, String locale) {
        return profiles.findByDeviceId(deviceId).orElseGet(() -> {
            Profile p = new Profile();
            p.id = UUID.randomUUID();
            p.deviceId = deviceId;
            p.displayName = displayName != null && !displayName.isBlank() ? displayName.strip() : randomNick();
            p.avatar = ThreadLocalRandom.current().nextInt(8);
            p.locale = locale != null && LOCALES.contains(locale) ? locale : "de";
            profiles.save(p);
            profiles.flush();
            events.publishEvent(new UserRegistered(p.id));
            return p;
        });
    }

    /** Turns the current guest into a permanent account, so progress survives a new device. */
    @Transactional
    Profile register(UUID userId, String email, String password, String displayName) {
        String normalized = email.strip().toLowerCase();
        if (profiles.findByEmail(normalized).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "email already registered");
        }
        Profile p = load(userId);
        if (p.email != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "account already registered");
        }
        p.email = normalized;
        p.passwordHash = encoder.encode(password);
        // From now on only the password opens this account. A stale device id must not.
        p.deviceId = null;
        if (displayName != null && !displayName.isBlank()) {
            p.displayName = displayName.strip();
        }
        return p;
    }

    @Transactional(readOnly = true)
    Profile login(String email, String password) {
        return profiles.findByEmail(email.strip().toLowerCase())
                .filter(p -> p.passwordHash != null && encoder.matches(password, p.passwordHash))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "invalid credentials"));
    }

    @Override
    @Transactional(readOnly = true)
    public UserRef require(UUID userId) {
        return load(userId).ref();
    }

    @Override
    @Transactional(readOnly = true)
    public Map<UUID, UserRef> find(Collection<UUID> userIds) {
        Map<UUID, UserRef> out = new LinkedHashMap<>();
        profiles.findAllById(userIds).forEach(p -> out.put(p.id, p.ref()));
        return out;
    }

    @Override
    @Transactional
    public UUID ensureManager(String email, String password, String displayName, UUID orgId) {
        Profile p = profiles.findByEmail(email).orElseGet(() -> {
            Profile n = new Profile();
            n.id = UUID.randomUUID();
            n.email = email;
            n.displayName = displayName;
            n.role = "MANAGER";
            return n;
        });
        p.passwordHash = encoder.encode(password);
        p.orgId = orgId;
        profiles.save(p);
        return p.id;
    }

    @Override
    @Transactional
    public void assignOrg(UUID userId, UUID orgId) {
        load(userId).orgId = orgId;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<UUID> orgOf(UUID userId) {
        return profiles.findById(userId).map(p -> p.orgId);
    }

    @Override
    @Transactional
    public void updateSettings(UUID userId, SettingsChange c) {
        Profile p = load(userId);
        if (c.displayName() != null && !c.displayName().isBlank()) {
            p.displayName = c.displayName().strip();
        }
        if (c.avatar() != null) {
            p.avatar = Math.floorMod(c.avatar(), 8);
        }
        if (c.locale() != null && LOCALES.contains(c.locale())) {
            p.locale = c.locale();
        }
        if (c.mode() != null && MODES.contains(c.mode())) {
            p.mode = c.mode();
        }
        if (c.publicBoard() != null) {
            p.publicBoard = c.publicBoard();
        }
    }

    @Override
    @Transactional
    public void deleteAccount(UUID userId) {
        profiles.deleteById(userId);
    }

    private Profile load(UUID id) {
        return profiles.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "unknown user"));
    }

    private static String randomNick() {
        var r = ThreadLocalRandom.current();
        return NICK_A.get(r.nextInt(NICK_A.size())) + " " + NICK_B.get(r.nextInt(NICK_B.size()));
    }
}
