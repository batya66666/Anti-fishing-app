package de.koeder.duel.internal;

import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

/**
 * In-memory queue: matches by rating, widening the window every 5 s.
 * After the fallback time a bot takes over, so nobody ever waits for long and the demo works alone.
 */
@Service
class Matchmaking {

    private static final String CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O, 1/I: read aloud on stage
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int BASE_WINDOW = 100;
    private static final int WINDOW_STEP = 100;

    private final DuelEngine engine;
    private final SimpMessagingTemplate broker;
    private final Clock clock;
    private final Duration botAfter;
    private final ConcurrentLinkedQueue<Entry> queue = new ConcurrentLinkedQueue<>();
    private final Map<String, UUID> friendlyCodes = new ConcurrentHashMap<>();

    Matchmaking(DuelEngine engine, SimpMessagingTemplate broker, Clock clock,
                @Value("${koeder.duel.bot-fallback-seconds}") long botFallbackSeconds) {
        this.engine = engine;
        this.broker = broker;
        this.clock = clock;
        this.botAfter = Duration.ofSeconds(botFallbackSeconds);
    }

    private record Entry(UUID userId, int elo, Instant joinedAt) {
    }

    void join(UUID userId) {
        leave(userId);
        queue.add(new Entry(userId, engine.rating(userId).elo(), clock.instant()));
    }

    void leave(UUID userId) {
        queue.removeIf(e -> e.userId.equals(userId));
    }

    @Scheduled(fixedDelay = 1000)
    synchronized void tick() {
        Instant now = clock.instant();
        List<Entry> waiting = new ArrayList<>(queue);
        List<Entry> matched = new ArrayList<>();
        for (int i = 0; i < waiting.size(); i++) {
            Entry a = waiting.get(i);
            if (matched.contains(a)) {
                continue;
            }
            for (int j = i + 1; j < waiting.size(); j++) {
                Entry b = waiting.get(j);
                if (matched.contains(b)) {
                    continue;
                }
                if (Math.abs(a.elo - b.elo) <= Math.max(window(a, now), window(b, now))) {
                    matched.add(a);
                    matched.add(b);
                    announce(engine.create(a.userId, b.userId, "ranked"));
                    break;
                }
            }
            if (!matched.contains(a) && Duration.between(a.joinedAt, now).compareTo(botAfter) >= 0) {
                matched.add(a);
                announce(engine.create(a.userId, null, "ranked"));
            }
        }
        queue.removeAll(matched);
    }

    private static int window(Entry e, Instant now) {
        return BASE_WINDOW + WINDOW_STEP * (int) (Duration.between(e.joinedAt, now).toSeconds() / 5);
    }

    String createFriendly(UUID hostId) {
        friendlyCodes.values().removeIf(hostId::equals);
        String code;
        do {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 6; i++) {
                sb.append(CODE_ALPHABET.charAt(RANDOM.nextInt(CODE_ALPHABET.length())));
            }
            code = sb.toString();
        } while (friendlyCodes.putIfAbsent(code, hostId) != null);
        return code;
    }

    DuelState joinFriendly(String code, UUID guestId) {
        String normalized = code.strip().toUpperCase();
        UUID host = friendlyCodes.get(normalized);
        if (host == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "unknown code");
        }
        if (host.equals(guestId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "cannot join your own duel");
        }
        if (!friendlyCodes.remove(normalized, host)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "duel already started");
        }
        DuelState duel = engine.create(host, guestId, "friendly");
        announce(duel);
        return duel;
    }

    /** The host waited long enough: start against a bot rather than stare at an empty stage. */
    DuelState friendlyWithBot(UUID hostId) {
        friendlyCodes.values().removeIf(hostId::equals);
        DuelState duel = engine.create(hostId, null, "friendly");
        announce(duel);
        return duel;
    }

    private void announce(DuelState d) {
        Map<String, Object> message = Map.of("duelId", d.id.toString());
        if (d.a.userId != null) {
            broker.convertAndSendToUser(d.a.userId.toString(), "/queue/match-found", message);
        }
        if (d.b.userId != null) {
            broker.convertAndSendToUser(d.b.userId.toString(), "/queue/match-found", message);
        }
    }
}
