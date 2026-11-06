package de.koeder.progression.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;

class ProgressionRulesTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 11, 6);

    @Test
    void firstEverAnswerStartsAStreak() {
        assertThat(ProgressionService.nextStreak(null, TODAY, 0, 1)).isEqualTo(new ProgressionService.StreakChange(1, 0));
    }

    @Test
    void secondAnswerOnTheSameDayChangesNothing() {
        assertThat(ProgressionService.nextStreak(TODAY, TODAY, 5, 1).streak()).isEqualTo(5);
    }

    @Test
    void consecutiveDaysGrowTheStreak() {
        assertThat(ProgressionService.nextStreak(TODAY.minusDays(1), TODAY, 5, 0).streak()).isEqualTo(6);
    }

    @Test
    void aFreezeCoversOneMissedDay() {
        assertThat(ProgressionService.nextStreak(TODAY.minusDays(2), TODAY, 5, 1)).isEqualTo(new ProgressionService.StreakChange(6, 1));
    }

    @Test
    void withoutAFreezeOrAfterALongBreakTheStreakRestarts() {
        assertThat(ProgressionService.nextStreak(TODAY.minusDays(2), TODAY, 5, 0).streak()).isEqualTo(1);
        assertThat(ProgressionService.nextStreak(TODAY.minusDays(9), TODAY, 5, 3)).isEqualTo(new ProgressionService.StreakChange(1, 0));
    }

    @Test
    void levelsFollowXpAndEndAtCiso() {
        assertThat(Levels.levelFor(0)).isEqualTo(1);
        assertThat(Levels.levelFor(149)).isEqualTo(1);
        assertThat(Levels.levelFor(150)).isEqualTo(2);
        assertThat(Levels.title(Levels.levelFor(999_999))).isEqualTo("CISO");
    }
}
