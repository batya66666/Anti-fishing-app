package de.koeder.ai.internal;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import de.koeder.ai.AiApi.CheckResult;
import de.koeder.ai.AiApi.Finding;

/**
 * Offline analysis of a suspicious message using the checklist from the curriculum.
 * Used when no API key is configured or the API fails, so the feature never dies on stage.
 */
final class RuleEngine {

    private static final Pattern URL = Pattern.compile("(?i)\\b((?:https?://|www\\.)[^\\s<>\"')]+|[a-z0-9-]+(?:\\.[a-z0-9-]+)*\\.(?:com|de|net|org|info|xyz|top|click|shop|link|ru|cn|example|test|invalid)(?:/[^\\s<>\"')]*)?)");
    private static final Pattern DANGEROUS_FILE = Pattern.compile("(?i)\\b[\\w\\-. ]+\\.(exe|scr|com|pif|bat|cmd|ps1|vbs|js|wsf|hta|lnk|iso|img|vhd|docm|xlsm|pptm|one|apk)\\b");
    private static final Pattern URGENCY = Pattern.compile("(?i)(dringend|sofort|umgehend|innerhalb von \\d+|letzte (mahnung|warnung)|gesperrt|sperrung|läuft ab|urgent|immediately|within \\d+|final notice|suspended|expires?)");
    private static final Pattern CREDENTIALS = Pattern.compile("(?i)(passwort|kennwort|pin\\b|tan\\b|2fa|bestätigungscode|zugangsdaten|kartendaten|cvv|password|verification code|credentials|card details)");
    private static final Pattern PAYMENT = Pattern.compile("(?i)(bankverbindung|iban|überweis|neue kontodaten|gutschein|geschenkkarte|bitcoin|krypto|wire transfer|bank details|gift card|crypto)");
    private static final Pattern SECRECY = Pattern.compile("(?i)(vertraulich|niemandem|nicht weitersagen|unter uns|confidential|don't tell|do not tell|keep this between)");
    private static final Pattern TOO_GOOD = Pattern.compile("(?i)(gewonnen|gewinn|rückerstattung|erstattung|bonus|you won|refund|prize|lottery)");
    private static final Pattern NEW_NUMBER = Pattern.compile("(?i)(neue nummer|hallo mama|hallo papa|new number|hi mum|hi mom|hi dad)");
    private static final Pattern GENERIC = Pattern.compile("(?i)(sehr geehrter kunde|lieber kunde|dear customer|dear user)");
    private static final Pattern SHORTENER = Pattern.compile("(?i)\\b(bit\\.ly|tinyurl\\.com|t\\.co|goo\\.gl|ow\\.ly|is\\.gd)\\b");
    private static final Pattern RISKY_TLD = Pattern.compile("(?i)\\.(xyz|top|click|shop|link|ru|cn|info)(/|$)");

    private RuleEngine() {
    }

    static CheckResult analyze(String input, String locale) {
        String text = input == null ? "" : input;
        boolean de = !"en".equals(locale);
        List<Finding> findings = new ArrayList<>();
        int score = 0;

        Matcher file = DANGEROUS_FILE.matcher(text);
        if (file.find()) {
            score += 45;
            findings.add(new Finding(de ? "Gefährlicher Dateityp" : "Dangerous file type",
                    (de ? "\"%s\" kann Programmcode ausführen. Nicht öffnen." : "\"%s\" can run code. Do not open it.").formatted(file.group().strip())));
        }
        if (CREDENTIALS.matcher(text).find()) {
            score += 30;
            findings.add(new Finding(de ? "Fragt nach Zugangsdaten" : "Asks for credentials",
                    de ? "Banken, IT und Behörden fragen nie per Nachricht nach Passwort, PIN oder TAN." : "Banks, IT and authorities never ask for passwords, PINs or codes by message."));
        }
        if (PAYMENT.matcher(text).find()) {
            score += 25;
            findings.add(new Finding(de ? "Geht um Geld oder Bankdaten" : "Money or bank details",
                    de ? "Prüfe Zahlungsänderungen immer über einen zweiten, bekannten Kanal." : "Always confirm payment changes through a second, known channel."));
        }
        if (URGENCY.matcher(text).find()) {
            score += 20;
            findings.add(new Finding(de ? "Künstlicher Zeitdruck" : "Artificial urgency",
                    de ? "Zeitdruck soll dich vom Nachdenken abhalten." : "Pressure is there to stop you from thinking."));
        }
        if (SECRECY.matcher(text).find()) {
            score += 20;
            findings.add(new Finding(de ? "Bitte um Geheimhaltung" : "Request for secrecy",
                    de ? "\"Sag niemandem etwas\" verhindert, dass jemand den Betrug bemerkt." : "\"Tell nobody\" stops anyone from noticing the fraud."));
        }
        if (NEW_NUMBER.matcher(text).find()) {
            score += 35;
            findings.add(new Finding(de ? "Masche \"neue Nummer\"" : "\"New number\" scam",
                    de ? "Rufe die Person unter der alten, bekannten Nummer zurück." : "Call the person back on the old, known number."));
        }
        if (TOO_GOOD.matcher(text).find()) {
            score += 15;
            findings.add(new Finding(de ? "Zu schön, um wahr zu sein" : "Too good to be true",
                    de ? "Unerwartete Gewinne und Erstattungen sind ein klassischer Köder." : "Unexpected prizes and refunds are classic bait."));
        }
        if (GENERIC.matcher(text).find()) {
            score += 10;
            findings.add(new Finding(de ? "Allgemeine Anrede" : "Generic greeting",
                    de ? "Echte Dienste kennen meist deinen Namen." : "Real services usually know your name."));
        }

        Matcher url = URL.matcher(text);
        boolean hasLink = false;
        while (url.find()) {
            String link = url.group(1).toLowerCase(Locale.ROOT);
            if (DANGEROUS_FILE.matcher(link).find() && !link.contains("/")) {
                continue;
            }
            hasLink = true;
            String host = host(link);
            if (SHORTENER.matcher(link).find()) {
                score += 20;
                findings.add(new Finding(de ? "Verkürzter Link" : "Shortened link",
                        (de ? "%s verbirgt das echte Ziel." : "%s hides the real destination.").formatted(host)));
            } else if (host.startsWith("xn--") || host.contains(".xn--")) {
                score += 35;
                findings.add(new Finding(de ? "Punycode-Domain" : "Punycode domain",
                        (de ? "%s kann mit ähnlich aussehenden Zeichen eine bekannte Marke imitieren." : "%s can imitate a well-known brand with look-alike characters.").formatted(host)));
            } else if (RISKY_TLD.matcher(host + "/").find()) {
                score += 20;
                findings.add(new Finding(de ? "Auffällige Domain-Endung" : "Unusual domain ending",
                        (de ? "%s nutzt eine Endung, die oft für kurzlebige Betrugsseiten verwendet wird." : "%s uses an ending often seen on short-lived fraud sites.").formatted(host)));
            } else if (host.chars().filter(c -> c == '.').count() >= 3) {
                score += 20;
                findings.add(new Finding(de ? "Viele Subdomains" : "Many subdomains",
                        (de ? "Bei %s zählt nur der Teil direkt vor der Endung." : "In %s only the part right before the ending counts.").formatted(host)));
            }
        }
        if (hasLink && findings.isEmpty()) {
            score += 10;
            findings.add(new Finding(de ? "Enthält einen Link" : "Contains a link",
                    de ? "Rufe die Seite lieber direkt über dein Lesezeichen auf." : "Rather open the site through your own bookmark."));
        }
        if (hasLink && score >= 30) {
            score += 10;
        }

        score = Math.min(score, 98);
        String verdict = score >= 50 ? "dangerous" : (score >= 20 ? "suspicious" : "unclear");
        String recommendation = switch (verdict) {
            case "dangerous" -> de
                    ? "Nicht klicken, nicht antworten. Im Büro: an die IT melden. Privat: löschen und den angeblichen Absender über einen bekannten Weg kontaktieren."
                    : "Don't click, don't reply. At work: report it to IT. At home: delete it and contact the alleged sender through a known channel.";
            case "suspicious" -> de
                    ? "Sei vorsichtig. Prüfe die Nachricht über einen zweiten Kanal, bevor du etwas tust."
                    : "Be careful. Verify through a second channel before doing anything.";
            default -> de
                    ? "Keine typischen Warnzeichen gefunden. Das ist keine Garantie: War die Nachricht unerwartet, frag lieber nach."
                    : "No typical warning signs found. That is no guarantee: if the message was unexpected, ask.";
        };
        return new CheckResult(verdict, score, findings, recommendation, "rules");
    }

    private static String host(String link) {
        String h = link.replaceFirst("^https?://", "").replaceFirst("^www\\.", "");
        int slash = h.indexOf('/');
        return slash >= 0 ? h.substring(0, slash) : h;
    }
}
