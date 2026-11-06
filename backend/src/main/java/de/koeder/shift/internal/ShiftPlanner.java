package de.koeder.shift.internal;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
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
            "mail-pdf-invoice-legit", "sms-parcel", "mail-invoice-exe", "call-ceo-fraud",
            "mail-supplier-legit", "mail-pdf-qr-payroll", "push-mfa-fatigue", "mail-it-maintenance");

    private ShiftPlanner() {
    }

    /** @param forced difficulty pinned by a manager, or null */
    static List<String> plan(List<Scenario> pool, Set<String> recentlySeen, boolean firstShift, boolean consumerOnly, int level, long seed, String forced) {
        if (forced == null && firstShift && !consumerOnly && pool.stream().map(Scenario::id).collect(Collectors.toSet()).containsAll(FIRST_SHIFT)) {
            return FIRST_SHIFT;
        }
        Random random = new Random(seed);
        List<Scenario> eligible = new ArrayList<>(pool.stream()
                .filter(s -> !consumerOnly || s.consumer())
                .filter(s -> forced != null ? s.fitsDifficulty(forced) : difficultyRank(s.difficulty()) <= maxDifficulty(level))
                .toList());
        Collections.shuffle(eligible, random);
        // Stable sort: unseen messages first, random order within each group.
        eligible.sort((a, b) -> Boolean.compare(recentlySeen.contains(a.id()), recentlySeen.contains(b.id())));

        Set<String> picked = new LinkedHashSet<>();
        if (forced == null) {
            // Even a beginner meets messages that are hard to tell apart: easy ones alone teach false confidence.
            List<Scenario> hard = eligible.stream().filter(ShiftPlanner::isHard).toList();
            int quota = hardQuota(level);
            takeMixed(hard, true, (quota + 1) / 2, picked);
            takeMixed(hard, false, quota / 2, picked);
        }
        fill(eligible, SHIFT_SIZE, picked);

        List<String> order = new ArrayList<>(picked);
        Collections.shuffle(order, random);
        return order;
    }

    /**
     * The next batch of the endless mode. It never runs dry: the messages seen longest ago come back first.
     *
     * @param lastSeen when the player last answered each scenario (any comparable clock value)
     * @param difficulty one level, or null for a mix in which half the batch is hard
     */
    static List<String> endless(List<Scenario> pool, Map<String, Long> lastSeen, String difficulty, boolean consumerOnly, int count, long seed) {
        Random random = new Random(seed);
        List<Scenario> eligible = new ArrayList<>(pool.stream()
                .filter(s -> !consumerOnly || s.consumer())
                .filter(s -> difficulty == null || s.fitsDifficulty(difficulty))
                .toList());
        if (eligible.isEmpty()) {
            eligible.addAll(pool); // a simple-mode player and a level without such content: better old than nothing
        }
        Collections.shuffle(eligible, random);
        eligible.sort(Comparator.comparingLong(s -> lastSeen.getOrDefault(s.id(), Long.MIN_VALUE)));

        Set<String> picked = new LinkedHashSet<>();
        if (difficulty == null) {
            List<Scenario> hard = eligible.stream().filter(ShiftPlanner::isHard).toList();
            takeMixed(hard, true, (count + 3) / 4, picked);
            takeMixed(hard, false, count / 4, picked);
        }
        fill(eligible, count, picked);

        List<String> order = new ArrayList<>(picked);
        Collections.shuffle(order, random);
        return order;
    }

    /** Tops {@code picked} up to {@code size}: half attacks, then anything if one kind ran out. */
    private static void fill(List<Scenario> eligible, int size, Set<String> picked) {
        Set<String> attacks = eligible.stream().filter(Scenario::attack).map(Scenario::id).collect(Collectors.toSet());
        long attacksPicked = picked.stream().filter(attacks::contains).count();
        takeMixed(eligible, true, Math.max(0, size / 2 - (int) attacksPicked), picked);
        takeMixed(eligible, false, Math.max(0, size - picked.size()), picked);
        eligible.stream().map(Scenario::id).takeWhile(id -> picked.size() < size).forEach(picked::add);
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

    private static boolean isHard(Scenario s) {
        return difficultyRank(s.difficulty()) >= 2;
    }

    /** How many of the 8 messages are Gold or Diamond. */
    static int hardQuota(int level) {
        return level >= 3 ? 4 : 3;
    }

    /** Beginners meet Gold from the start. Diamond unlocks at level 3. */
    static int maxDifficulty(int level) {
        return level >= 3 ? 3 : 2;
    }
}
