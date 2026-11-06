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
        List<String> plan = ShiftPlanner.plan(pool, Set.of(), false, false, 1, 42);
        assertThat(plan).hasSize(ShiftPlanner.SHIFT_SIZE).doesNotHaveDuplicates();
        assertThat(plan.stream().filter(id -> id.startsWith("a")).count()).isEqualTo(4);
    }

    @Test
    void sameSeedSameShift() {
        assertThat(ShiftPlanner.plan(pool(), Set.of(), false, false, 1, 7)).isEqualTo(ShiftPlanner.plan(pool(), Set.of(), false, false, 1, 7));
    }

    @Test
    void recentlySeenMessagesComeLast() {
        Set<String> seen = new HashSet<>();
        for (int i = 0; i < 10; i++) {
            seen.add("a" + i);
            seen.add("l" + i);
        }
        assertThat(ShiftPlanner.plan(pool(), seen, false, false, 1, 3)).doesNotContainAnyElementsOf(seen);
    }

    @Test
    void beginnersDoNotGetDiamondAttacks() {
        for (long seed = 0; seed < 25; seed++) {
            assertThat(ShiftPlanner.plan(pool(), Set.of(), false, false, 1, seed)).doesNotContain("a99");
        }
    }

    @Test
    void simpleModeOnlyPlaysConsumerContent() {
        List<Scenario> pool = pool();
        Set<String> consumer = new HashSet<>();
        pool.stream().filter(Scenario::consumer).forEach(s -> consumer.add(s.id()));
        assertThat(consumer).containsAll(ShiftPlanner.plan(pool, Set.of(), true, true, 1, 11));
    }
}
