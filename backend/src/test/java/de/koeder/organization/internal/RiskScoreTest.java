package de.koeder.organization.internal;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class RiskScoreTest {

    @Test
    void tooLittleDataShowsNoScore() {
        assertThat(RiskScore.of(4, 2, 2, 0, 0)).isNull();
    }

    @Test
    void everyoneReportingEveryAttackIsZeroRisk() {
        assertThat(RiskScore.of(100, 50, 0, 50, 0)).isZero();
    }

    @Test
    void everyoneFallingForEverythingIsHighRisk() {
        assertThat(RiskScore.of(100, 50, 50, 0, 0)).isEqualTo(90);
    }

    @Test
    void reportingEverythingIncludingGenuineMailIsNotTheOptimum() {
        assertThat(RiskScore.of(100, 50, 0, 50, 50)).isGreaterThan(RiskScore.of(100, 50, 0, 50, 0));
    }
}
