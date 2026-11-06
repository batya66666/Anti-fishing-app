package de.koeder.ai.internal;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import de.koeder.ai.AiApi.CompanyProfile;
import de.koeder.content.Scenario;
import de.koeder.content.Scenario.RedFlag;

/**
 * Fills fixed training templates with the company profile. Not AI: it is the fallback when no API key
 * is available, and the response marks it as "template" so nobody mistakes it for generated content.
 */
final class TemplateGenerator {

    private TemplateGenerator() {
    }

    static List<Scenario> generate(CompanyProfile c, int count, String locale) {
        boolean de = !"en".equals(locale);
        String slug = c.name() == null ? "firma" : c.name().toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
        if (slug.isEmpty()) {
            slug = "firma";
        }
        String domain = slug + ".example";
        String tool = firstOf(c.tools(), de ? "das ERP-System" : "the ERP system");
        String partner = firstOf(c.partners(), de ? "Hauptlieferant GmbH" : "Main Supplier Ltd");
        String partnerSlug = partner.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");

        List<Scenario> all = new ArrayList<>();
        all.add(email("org-tpl-bank", locale, "gold", true, "invoice_fraud", 5,
                partner + " Buchhaltung", "buchhaltung@" + partnerSlug + "-zahlung.test",
                de ? "Neue Bankverbindung ab sofort gültig" : "New bank details effective immediately",
                de ? "Guten Tag,\n\nwegen einer Umstellung gilt ab sofort unsere neue Bankverbindung. Bitte passen Sie diese vor der nächsten Zahlung an und bestätigen Sie dies heute noch."
                        : "Hello,\n\ndue to a system change our new bank details apply immediately. Please update them before the next payment and confirm today.",
                List.of(), List.of(),
                List.of(new RedFlag("from_email", de ? "Die Domain gehört nicht zu " + partner + "." : "This domain does not belong to " + partner + "."),
                        new RedFlag(de ? "body:heute noch" : "body:confirm today", de ? "Zeitdruck bei einer Bankänderung ist ein Alarmsignal." : "Time pressure on a bank change is an alarm signal.")),
                List.of("report", "delete"), List.of("reply"),
                de ? "Bankänderungen immer telefonisch unter der bekannten Nummer prüfen." : "Always verify bank changes by phone using the known number."));
        all.add(email("org-tpl-tool", locale, "silver", true, "credential_phishing", 3,
                tool + " Support", "support@" + slug + "-login.test",
                (de ? "Ihr Zugang zu %s läuft heute ab" : "Your %s access expires today").formatted(tool),
                de ? "Bitte melden Sie sich innerhalb von 24 Stunden erneut an, sonst wird Ihr Konto gesperrt." : "Please sign in again within 24 hours or your account will be locked.",
                List.of(Map.of("text", de ? "Jetzt anmelden" : "Sign in now", "href", "https://" + slug + "-login.test/session")), List.of(),
                List.of(new RedFlag("from_email", de ? "Absender kommt nicht von " + domain + "." : "Sender is not from " + domain + "."),
                        new RedFlag("link:0", de ? "Der Link führt auf eine fremde Domain." : "The link leads to a foreign domain."),
                        new RedFlag(de ? "body:innerhalb von 24 Stunden" : "body:within 24 hours", de ? "Künstlicher Zeitdruck." : "Artificial urgency.")),
                List.of("report", "delete"), List.of("click_link"),
                (de ? "Melde dich bei %s nur über das bekannte Lesezeichen an." : "Only sign in to %s through your known bookmark.").formatted(tool)));
        all.add(email("org-tpl-ceo", locale, "gold", true, "ceo_fraud", 5,
                de ? "Geschäftsführung " + c.name() : "CEO " + c.name(), "gf." + slug + "@freemail.test",
                de ? "Vertraulich: dringende Überweisung" : "Confidential: urgent transfer",
                de ? "Ich bin in einer Besprechung und nicht erreichbar. Bitte veranlassen Sie heute vertraulich eine Überweisung an einen neuen Partner. Sprechen Sie mit niemandem darüber."
                        : "I am in a meeting and cannot be reached. Please arrange a confidential transfer to a new partner today. Do not talk to anyone about it.",
                List.of(), List.of(),
                List.of(new RedFlag("from_email", de ? "Die Geschäftsführung schreibt nicht von einem Freemail-Konto." : "Management does not write from a free mail account."),
                        new RedFlag(de ? "body:mit niemandem" : "body:Do not talk to anyone", de ? "Geheimhaltung soll die Kontrolle umgehen." : "Secrecy is meant to bypass controls.")),
                List.of("report", "delete"), List.of("reply"),
                de ? "CEO-Fraud: Rückfrage über einen bekannten Kanal, Vier-Augen-Prinzip einhalten." : "CEO fraud: check back through a known channel and keep the four-eyes principle."));
        all.add(email("org-tpl-legit", locale, "silver", false, null, 2,
                "IT " + c.name(), "it@" + domain,
                (de ? "Wartung von %s am Samstag" : "%s maintenance on Saturday").formatted(tool),
                de ? "Hallo zusammen,\n\nam Samstag ist %s von 8 bis 12 Uhr nicht erreichbar. Sie müssen nichts tun.".formatted(tool) : "Hi all,\n\non Saturday %s will be unavailable from 8 to 12. No action is needed.".formatted(tool),
                List.of(), List.of(), List.of(), List.of("open"), List.of(),
                de ? "Echte Nachricht: interner Absender, kein Link, kein Druck, keine Aufforderung." : "Genuine: internal sender, no link, no pressure, nothing to do."));
        return all.subList(0, Math.min(Math.max(count, 1), all.size()));
    }

    private static String firstOf(String list, String fallback) {
        if (list == null || list.isBlank()) {
            return fallback;
        }
        return list.split("[,;]")[0].strip();
    }

    private static Scenario email(String id, String locale, String difficulty, boolean attack, String attackType, int module,
                                  String fromName, String fromEmail, String subject, String body, List<Map<String, String>> links,
                                  List<Map<String, Object>> attachments, List<RedFlag> flags, List<String> correct, List<String> dangerous,
                                  String explanation) {
        Map<String, Object> content = Map.of("from_name", fromName, "from_email", fromEmail, "subject", subject, "body_md", body,
                "links", links, "attachments", attachments);
        return new Scenario(id, "email", locale, difficulty, attack, attackType, module, false, content, flags, correct, dangerous,
                explanation, List.of("company"), null);
    }
}
