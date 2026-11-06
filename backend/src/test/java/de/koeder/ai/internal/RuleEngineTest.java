package de.koeder.ai.internal;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import de.koeder.ai.AiApi.CheckResult;

class RuleEngineTest {

    @Test
    void parcelScamIsAtLeastSuspicious() {
        CheckResult r = RuleEngine.analyze("Ihr Paket konnte nicht zugestellt werden. Zahlen Sie sofort 1,99 €: paket-zustellung.xyz/x7", "de");
        assertThat(r.verdict()).isIn("suspicious", "dangerous");
        assertThat(r.findings()).isNotEmpty();
        assertThat(r.source()).isEqualTo("rules");
    }

    @Test
    void doubleExtensionAndUrgencyAreDangerous() {
        CheckResult r = RuleEngine.analyze("Dringend! Die Rechnung im Anhang öffnen: Rechnung_2026.pdf.exe. Bitte Passwort bestätigen.", "de");
        assertThat(r.verdict()).isEqualTo("dangerous");
        assertThat(r.findings()).anyMatch(f -> f.title().contains("Dateityp"));
    }

    @Test
    void newNumberScamIsRecognised() {
        CheckResult r = RuleEngine.analyze("Hallo Mama, das ist meine neue Nummer. Kannst du mir Geld überweisen?", "de");
        assertThat(r.riskScore()).isGreaterThanOrEqualTo(50);
    }

    @Test
    void harmlessMessageIsNeverCalledSafe() {
        CheckResult r = RuleEngine.analyze("Treffen wir uns um 12 Uhr in der Kantine?", "de");
        assertThat(r.verdict()).isEqualTo("unclear");
        assertThat(r.recommendation()).contains("keine Garantie");
    }

    @Test
    void answersInEnglishWhenAsked() {
        CheckResult r = RuleEngine.analyze("URGENT: your account is suspended, enter your password at login-check.xyz", "en");
        assertThat(r.findings()).anyMatch(f -> f.title().equals("Asks for credentials"));
    }
}
