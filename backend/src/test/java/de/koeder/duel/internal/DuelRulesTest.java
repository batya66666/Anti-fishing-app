package de.koeder.duel.internal;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class DuelRulesTest {

    @Test
    void equalRatingsExpectFiftyPercent() {
        assertThat(EloCalculator.expected(1000, 1000)).isEqualTo(0.5);
    }

    @Test
    void fourHundredPointsAheadExpectsTenToOne() {
        assertThat(EloCalculator.expected(1400, 1000)).isCloseTo(10.0 / 11.0, org.assertj.core.data.Offset.offset(1e-9));
    }

    @Test
    void winAgainstEqualGainsHalfOfK() {
        assertThat(EloCalculator.delta(1000, 1000, 1, 50)).isEqualTo(16);
        assertThat(EloCalculator.delta(1000, 1000, 1, 0)).isEqualTo(20); // new players move faster
    }

    @Test
    void lossIsTheMirrorImageOfAWinForEstablishedPlayers() {
        assertThat(EloCalculator.delta(1200, 1000, 1, 50)).isEqualTo(-EloCalculator.delta(1000, 1200, 0, 50));
    }

    @Test
    void upsetPaysMoreThanExpectedWin() {
        assertThat(EloCalculator.delta(1000, 1400, 1, 50)).isGreaterThan(EloCalculator.delta(1400, 1000, 1, 50));
    }

    @Test
    void wrongAnswerScoresZeroHoweverFast() {
        assertThat(DuelScoring.verdictPoints(false, 0)).isZero();
    }

    @Test
    void speedBonusFallsLinearlyOverTenSeconds() {
        assertThat(DuelScoring.verdictPoints(true, 0)).isEqualTo(150);
        assertThat(DuelScoring.verdictPoints(true, 5_000)).isEqualTo(125);
        assertThat(DuelScoring.verdictPoints(true, 10_000)).isEqualTo(100);
        assertThat(DuelScoring.verdictPoints(true, 14_000)).isEqualTo(100);
    }

    @Test
    void flagRoundPunishesWildTappingAndStaysInRange() {
        assertThat(DuelScoring.flagPoints(3, 0)).isEqualTo(150);
        assertThat(DuelScoring.flagPoints(2, 2)).isEqualTo(50);
        assertThat(DuelScoring.flagPoints(0, 5)).isZero();
        assertThat(DuelScoring.flagPoints(9, 0)).isEqualTo(150);
    }

    private static double rightOn(DuelBot.Level level, String difficulty) {
        return DuelBot.picked(level).accuracy(difficulty, "swipe", 0, 0, false);
    }

    @Test
    void strongerBotsAreRightMoreOftenAndHardMessagesCostThemAll() {
        assertThat(rightOn(DuelBot.Level.ROOKIE, "gold")).isLessThan(rightOn(DuelBot.Level.ANALYST, "gold"));
        assertThat(rightOn(DuelBot.Level.ANALYST, "gold")).isLessThan(rightOn(DuelBot.Level.VETERAN, "gold"));
        assertThat(rightOn(DuelBot.Level.VETERAN, "gold")).isLessThan(rightOn(DuelBot.Level.CISO, "gold"));
        for (DuelBot.Level level : DuelBot.Level.values()) {
            assertThat(rightOn(level, "diamond")).isLessThan(rightOn(level, "bronze"));
        }
    }

    @Test
    void aMatchedBotKeepsAGameCloseAPickedOneDoesNot() {
        DuelBot.Profile matched = DuelBot.forRating(1000);
        double even = matched.accuracy("silver", "swipe", 300, 300, false);
        assertThat(matched.accuracy("silver", "swipe", 0, 300, false)).isGreaterThan(even);
        assertThat(matched.accuracy("silver", "swipe", 300, 0, false)).isLessThan(even);
        DuelBot.Profile picked = DuelBot.picked(DuelBot.Level.CISO);
        assertThat(picked.accuracy("gold", "swipe", 300, 0, false)).isEqualTo(picked.accuracy("gold", "swipe", 0, 300, false));
    }

    @Test
    void aRushedBotMakesMoreMistakes() {
        DuelBot.Profile bot = DuelBot.picked(DuelBot.Level.ANALYST);
        assertThat(bot.accuracy("silver", "swipe", 0, 0, true)).isLessThan(bot.accuracy("silver", "swipe", 0, 0, false));
    }

    @Test
    void aBotReadsLongTextsLongerAndAlwaysAnswersInTime() {
        java.util.Random random = new java.util.Random(4);
        for (DuelBot.Level level : DuelBot.Level.values()) {
            DuelBot.Profile bot = DuelBot.picked(level);
            long shortTexts = 0;
            long longTexts = 0;
            for (int i = 0; i < 200; i++) {
                long quick = bot.thinkMs("silver", 100, "swipe", 15000, random);
                long slow = bot.thinkMs("silver", 800, "swipe", 15000, random);
                assertThat(quick).isBetween(900L, 13800L);
                assertThat(slow).isBetween(900L, 13800L);
                shortTexts += quick;
                longTexts += slow;
            }
            assertThat(longTexts).isGreaterThan(shortTexts);
        }
    }

    @Test
    void aCisoBeatsAnInternOnSpeedToo() {
        java.util.Random random = new java.util.Random(4);
        long intern = 0;
        long ciso = 0;
        for (int i = 0; i < 200; i++) {
            intern += DuelBot.picked(DuelBot.Level.ROOKIE).thinkMs("gold", 500, "swipe", 15000, random);
            ciso += DuelBot.picked(DuelBot.Level.CISO).thinkMs("gold", 500, "swipe", 15000, random);
        }
        assertThat(ciso).isLessThan(intern);
    }

    @Test
    void aWeakBotTapsHarmlessThingsAndAStrongOneRarely() {
        java.util.Random random = new java.util.Random(9);
        int weakWrong = 0;
        int strongWrong = 0;
        for (int i = 0; i < 500; i++) {
            weakWrong += DuelBot.tapFlags(java.util.List.of("from_email", "link:0"), 0.4, random).contains("subject") ? 1 : 0;
            strongWrong += DuelBot.tapFlags(java.util.List.of("from_email", "link:0"), 0.95, random).contains("subject") ? 1 : 0;
        }
        assertThat(weakWrong).isGreaterThan(strongWrong);
    }

    @Test
    void unknownLevelsMatchThePlayer() {
        assertThat(DuelBot.Level.parse("ciso")).isEqualTo(DuelBot.Level.CISO);
        assertThat(DuelBot.Level.parse("nonsense")).isNull();
        assertThat(DuelBot.Level.parse(null)).isNull();
    }
}
