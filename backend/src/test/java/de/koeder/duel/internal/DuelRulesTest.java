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
}
