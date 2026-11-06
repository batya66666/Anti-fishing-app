package de.koeder.content;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;

import de.koeder.content.Evaluation.Outcome;
import de.koeder.content.Scenario.RedFlag;

class ScenarioEvaluatorTest {

    private static Scenario attack() {
        return new Scenario("a", "email", "de", "silver", true, "invoice_fraud", 5, false, Map.of(),
                List.of(new RedFlag("from_email", "x"), new RedFlag("body:innerhalb von 24 Stunden", "y"), new RedFlag("attachment:0", "z")),
                List.of("report", "delete"), List.of("open_attachment"), "e", List.of(), null);
    }

    private static Scenario legit() {
        return new Scenario("l", "email", "de", "bronze", false, null, 1, false, Map.of(), List.of(),
                List.of("open", "reply"), List.of(), "e", List.of(), null);
    }

    @Test
    void reportingAnAttackBeatsDeletingIt() {
        Evaluation report = ScenarioEvaluator.evaluateAction(attack(), "report", 20_000);
        Evaluation delete = ScenarioEvaluator.evaluateAction(attack(), "delete", 20_000);
        assertThat(report.outcome()).isEqualTo(Outcome.CORRECT);
        assertThat(report.reported()).isTrue();
        assertThat(delete.outcome()).isEqualTo(Outcome.SAFE);
        assertThat(delete.reported()).isFalse();
        assertThat(report.points()).isGreaterThan(delete.points());
    }

    @Test
    void openingTheAttachmentGetsYouHacked() {
        Evaluation e = ScenarioEvaluator.evaluateAction(attack(), "open_attachment", 1000);
        assertThat(e.outcome()).isEqualTo(Outcome.HACKED);
        assertThat(e.correct()).isFalse();
        assertThat(e.points()).isZero();
    }

    @Test
    void reportingAGenuineMessageIsAFalseAlarm() {
        Evaluation e = ScenarioEvaluator.evaluateAction(legit(), "report", 1000);
        assertThat(e.outcome()).isEqualTo(Outcome.FALSE_ALARM);
        assertThat(e.correct()).isFalse();
        assertThat(e.reported()).isFalse();
    }

    @Test
    void answeringFastEarnsABonusButSlowStillPays() {
        int fast = ScenarioEvaluator.evaluateAction(legit(), "open", 0).points();
        int slow = ScenarioEvaluator.evaluateAction(legit(), "open", 60_000).points();
        assertThat(fast).isGreaterThan(slow);
        assertThat(slow).isEqualTo(ScenarioEvaluator.LEGIT_POINTS);
    }

    @Test
    void ignoringAnAttackIsMissedRatherThanCorrect() {
        Evaluation e = ScenarioEvaluator.evaluateAction(attack(), "open", 1000);
        assertThat(e.outcome()).isEqualTo(Outcome.MISSED);
    }

    @Test
    void swipeDecidesOnTheVerdictAlone() {
        assertThat(ScenarioEvaluator.evaluateVerdict(attack(), "attack", 500).correct()).isTrue();
        assertThat(ScenarioEvaluator.evaluateVerdict(attack(), "legit", 500).outcome()).isEqualTo(Outcome.HACKED);
        assertThat(ScenarioEvaluator.evaluateVerdict(legit(), "attack", 500).outcome()).isEqualTo(Outcome.FALSE_ALARM);
    }

    @Test
    void tappingASentenceWithTheFlaggedPhraseCounts() {
        Evaluation e = ScenarioEvaluator.evaluateFlags(attack(), List.of("from_email", "body:Bitte zahlen Sie innerhalb von 24 Stunden den Betrag."));
        assertThat(e.flagsFound()).isEqualTo(2);
        assertThat(e.flagsMissed()).isEqualTo(1);
        assertThat(e.flagsWrong()).isZero();
        assertThat(e.correct()).isTrue();
    }

    @Test
    void wildTappingLosesPoints() {
        Evaluation careful = ScenarioEvaluator.evaluateFlags(attack(), List.of("from_email"));
        Evaluation wild = ScenarioEvaluator.evaluateFlags(attack(), List.of("from_email", "subject", "body:Guten Tag", "link:0"));
        assertThat(wild.points()).isLessThan(careful.points());
        assertThat(wild.flagsWrong()).isEqualTo(3);
    }
}
