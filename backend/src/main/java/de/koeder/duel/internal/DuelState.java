package de.koeder.duel.internal;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.locks.ReentrantLock;

import de.koeder.content.Scenario;

/** A running match. Lives in memory only; the result goes to Postgres when it ends. */
final class DuelState {

    enum Phase { WAITING, COUNTDOWN, ROUND, RESULT, FINISHED }

    final ReentrantLock lock = new ReentrantLock();
    final UUID id;
    final String mode;
    final long seed;
    final Seat a;
    final Seat b;
    /** One entry per round, each mapping locale to that locale's version of the same scenario. */
    final List<Round> rounds;

    Phase phase = Phase.WAITING;
    int current = -1;
    Instant roundStartedAt;
    Instant createdAt = Instant.now();

    DuelState(UUID id, String mode, long seed, Seat a, Seat b, List<Round> rounds) {
        this.id = id;
        this.mode = mode;
        this.seed = seed;
        this.a = a;
        this.b = b;
        this.rounds = rounds;
    }

    Round round() {
        return rounds.get(current);
    }

    Seat seat(UUID userId) {
        if (a.userId != null && a.userId.equals(userId)) {
            return a;
        }
        return b.userId != null && b.userId.equals(userId) ? b : null;
    }

    boolean involves(UUID userId) {
        return seat(userId) != null;
    }

    static final class Seat {
        final String key; // "a" or "b"
        final UUID userId; // null for a bot
        final String name;
        final int avatar;
        final int elo;
        final int games;
        final String locale;
        /** Null for a person. */
        final DuelBot.Profile bot;
        boolean ready;
        int score;
        int correct;
        final List<Integer> perRound = new ArrayList<>();

        Seat(String key, UUID userId, String name, int avatar, int elo, int games, String locale, DuelBot.Profile bot) {
            this.key = key;
            this.userId = userId;
            this.name = name;
            this.avatar = avatar;
            this.elo = elo;
            this.games = games;
            this.locale = locale;
            this.bot = bot;
        }

        boolean isBot() {
            return userId == null;
        }
    }

    static final class Round {
        final int no;
        final String kind; // "swipe", "url", "flags"
        final Map<String, Scenario> byLocale;
        Answer answerA;
        Answer answerB;

        Round(int no, String kind, Map<String, Scenario> byLocale) {
            this.no = no;
            this.kind = kind;
            this.byLocale = byLocale;
        }

        Scenario canonical() {
            return byLocale.values().iterator().next();
        }

        Scenario forLocale(String locale) {
            Scenario s = byLocale.get(locale);
            return s != null ? s : canonical();
        }

        boolean bothAnswered() {
            return answerA != null && answerB != null;
        }
    }

    record Answer(String verdict, List<String> flags, long ms, int points, boolean correct) {
    }
}
