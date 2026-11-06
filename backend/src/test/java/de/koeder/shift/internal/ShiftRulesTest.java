package de.koeder.shift.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import org.junit.jupiter.api.Test;

import de.koeder.content.Scenario;

class ShiftRulesTest {

    @Test
    void leitnerClimbsTheBoxesAndGraduates() {
        assertThat(Leitner.nextBox(1, true)).contains(2);
        assertThat(Leitner.nextBox(4, true)).contains(5);
        assertThat(Leitner.nextBox(5, true)).isEqualTo(Optional.empty());
    }

    @Test
    void aNewMistakeStartsOverAtBoxOne() {
        assertThat(Leitner.nextBox(4, false)).contains(1);
        assertThat(Leitner.interval(1)).isEqualTo(Duration.ofDays(1));
    }

    @Test
    void intervalsFollowTheSpec() {
        assertThat(List.of(Leitner.interval(1), Leitner.interval(2), Leitner.interval(3), Leitner.interval(4)))
                .containsExactly(Duration.ofDays(1), Duration.ofDays(3), Duration.ofDays(7), Duration.ofDays(14));
    }

    private static Scenario scenario(int i, boolean attack, String type, String difficulty, boolean consumer) {
        return new Scenario((attack ? "a" : "l") + i, type, "de", difficulty, attack, attack ? "x" : null, 1, consumer,
                Map.of(), List.of(), List.of("report"), List.of(), "e", List.of(), null);
    }

    private static List<Scenario> pool() {
        List<Scenario> pool = new ArrayList<>();
        String[] types = {"email", "sms", "url", "qr"};
        for (int i = 0; i < 20; i++) {
            pool.add(scenario(i, true, types[i % 4], i % 2 == 0 ? "bronze" : "silver", i % 3 == 0));
            pool.add(scenario(i, false, types[i % 4], "bronze", i % 3 == 0));
        }
        pool.add(scenario(99, true, "email", "diamond", false));
        return pool;
    }

    @Test
    void aShiftIsHalfAttacksHalfGenuine() {
        List<Scenario> pool = pool();
        List<String> plan = ShiftPlanner.plan(pool, Set.of(), false, false, 1, 42, null);
        assertThat(plan).hasSize(ShiftPlanner.SHIFT_SIZE).doesNotHaveDuplicates();
        assertThat(plan.stream().filter(id -> id.startsWith("a")).count()).isEqualTo(4);
    }

    @Test
    void sameSeedSameShift() {
        assertThat(ShiftPlanner.plan(pool(), Set.of(), false, false, 1, 7, null)).isEqualTo(ShiftPlanner.plan(pool(), Set.of(), false, false, 1, 7, null));
    }

    @Test
    void recentlySeenMessagesComeLast() {
        Set<String> seen = new HashSet<>();
        for (int i = 0; i < 10; i++) {
            seen.add("a" + i);
            seen.add("l" + i);
        }
        assertThat(ShiftPlanner.plan(pool(), seen, false, false, 1, 3, null)).doesNotContainAnyElementsOf(seen);
    }

    @Test
    void beginnersDoNotGetDiamondAttacks() {
        for (long seed = 0; seed < 25; seed++) {
            assertThat(ShiftPlanner.plan(pool(), Set.of(), false, false, 1, seed, null)).doesNotContain("a99");
        }
    }

    private static List<Scenario> poolWithHard() {
        List<Scenario> pool = pool();
        for (int i = 100; i < 108; i++) {
            pool.add(scenario(i, true, "email", "gold", false));
            pool.add(scenario(i, false, "email", "gold", false));
        }
        return pool;
    }

    private static int number(String id) {
        return Integer.parseInt(id.substring(1));
    }

    @Test
    void evenABeginnerMeetsHardMessages() {
        for (long seed = 0; seed < 25; seed++) {
            List<String> plan = ShiftPlanner.plan(poolWithHard(), Set.of(), false, false, 1, seed, null);
            assertThat(plan).hasSize(ShiftPlanner.SHIFT_SIZE);
            assertThat(plan.stream().filter(id -> number(id) >= 100).count()).isGreaterThanOrEqualTo(ShiftPlanner.hardQuota(1));
            assertThat(plan.stream().filter(id -> id.startsWith("a")).count()).isEqualTo(4);
        }
    }

    @Test
    void aPinnedDifficultyDecidesTheShiftAndSkipsTheCuratedOne() {
        List<String> plan = ShiftPlanner.plan(poolWithHard(), Set.of(), true, false, 1, 5, "gold");
        assertThat(plan).hasSize(ShiftPlanner.SHIFT_SIZE).allMatch(id -> number(id) >= 100);
    }

    @Test
    void endlessNeverRunsDryAndBringsBackWhatWasSeenLongestAgo() {
        List<Scenario> pool = poolWithHard();
        Map<String, Long> seen = new java.util.HashMap<>();
        pool.forEach(s -> seen.put(s.id(), 1000L));
        seen.put("a0", 1L);
        seen.put("l0", 2L);
        assertThat(ShiftPlanner.endless(pool, seen, null, false, 10, 3)).hasSize(10).doesNotHaveDuplicates();
        assertThat(ShiftPlanner.endless(pool, seen, "bronze", false, 10, 3)).contains("a0", "l0");
    }

    @Test
    void endlessKeepsToTheChosenLevelAndStaysBalanced() {
        List<String> gold = ShiftPlanner.endless(poolWithHard(), Map.of(), "gold", false, 10, 8);
        assertThat(gold).hasSize(10).allMatch(id -> number(id) >= 100);
        assertThat(gold.stream().filter(id -> id.startsWith("a")).count()).isEqualTo(5);
    }

    @Test
    void endlessMixIsHalfHard() {
        List<String> mix = ShiftPlanner.endless(poolWithHard(), Map.of(), null, false, 10, 8);
        assertThat(mix.stream().filter(id -> number(id) >= 99).count()).isGreaterThanOrEqualTo(5);
    }

    @Test
    void simpleModeOnlyPlaysConsumerContent() {
        List<Scenario> pool = pool();
        Set<String> consumer = new HashSet<>();
        pool.stream().filter(Scenario::consumer).forEach(s -> consumer.add(s.id()));
        assertThat(consumer).containsAll(ShiftPlanner.plan(pool, Set.of(), true, true, 1, 11, null));
    }
}
