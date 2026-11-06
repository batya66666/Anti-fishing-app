package de.koeder.shift.internal;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

import de.koeder.content.Scenario;

/**
 * Builds a shift: 8 messages, half of them attacks, mixed channels, unseen messages first.
 * Half being genuine is deliberate: "everything is phishing" must not be a winning strategy.
 */
final class ShiftPlanner {

    static final int SHIFT_SIZE = 8;

    /** The first shift ever is curated: it tells the whole story of the product in one sitting. */
    static final List<String> FIRST_SHIFT = List.of(
            "mail-team-lunch", "sms-parcel", "mail-invoice-exe", "call-ceo-fraud",
            "mail-supplier-legit", "url-subdomain", "push-mfa-fatigue", "mail-it-maintenance");

    private ShiftPlanner() {
    }

    static List<String> plan(List<Scenario> pool, Set<String> recentlySeen, boolean firstShift, boolean consumerOnly, int level, long seed) {
        if (firstShift && !consumerOnly && pool.stream().map(Scenario::id).collect(Collectors.toSet()).containsAll(FIRST_SHIFT)) {
            return FIRST_SHIFT;
        }
        Random random = new Random(seed);
        List<Scenario> eligible = new ArrayList<>(pool.stream()
                .filter(s -> !consumerOnly || s.consumer())
                .filter(s -> difficultyRank(s.difficulty()) <= maxDifficulty(level))
                .toList());
        Collections.shuffle(eligible, random);
        // Stable sort: unseen messages first, random order within each group.
        eligible.sort((a, b) -> Boolean.compare(recentlySeen.contains(a.id()), recentlySeen.contains(b.id())));

        Set<String> picked = new LinkedHashSet<>();
        takeMixed(eligible, true, SHIFT_SIZE / 2, picked);
        takeMixed(eligible, false, SHIFT_SIZE - picked.size(), picked);
        // One kind ran out: fill up with anything rather than ship a short shift.
        eligible.stream().map(Scenario::id).takeWhile(id -> picked.size() < SHIFT_SIZE).forEach(picked::add);

        List<String> order = new ArrayList<>(picked);
        Collections.shuffle(order, random);
        return order;
    }

    /** Takes up to {@code count} scenarios of one kind, preferring channels not used yet. */
    private static void takeMixed(List<Scenario> source, boolean attack, int count, Set<String> picked) {
        List<Scenario> kind = source.stream().filter(s -> s.attack() == attack).toList();
        Set<String> channels = new HashSet<>();
        int taken = 0;
        for (Scenario s : kind) {
            if (taken < count && channels.add(s.type()) && picked.add(s.id())) {
                taken++;
            }
        }
        for (Scenario s : kind) {
            if (taken < count && picked.add(s.id())) {
                taken++;
            }
        }
    }

    static int difficultyRank(String difficulty) {
        return switch (difficulty) {
            case "bronze" -> 0;
            case "silver" -> 1;
            case "gold" -> 2;
            default -> 3;
        };
    }

    /** Harder attacks unlock as the player climbs: Gold from level 3, Diamond from level 5. */
    static int maxDifficulty(int level) {
        if (level >= 5) {
            return 3;
        }
        return level >= 3 ? 2 : 1;
    }
}
