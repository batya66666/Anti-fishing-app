package de.koeder.organization.internal;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.openpdf.text.Document;
import org.openpdf.text.Element;
import org.openpdf.text.Font;
import org.openpdf.text.FontFactory;
import org.openpdf.text.PageSize;
import org.openpdf.text.Paragraph;
import org.openpdf.text.Phrase;
import org.openpdf.text.pdf.PdfPCell;
import org.openpdf.text.pdf.PdfPTable;
import org.openpdf.text.pdf.PdfWriter;
import org.springframework.stereotype.Component;

/** Audit evidence for NIS2, ISO 27001 and TISAX: what the organisation does, with no individual's errors in it. */
@Component
class ComplianceReport {

    private static final Color INK = new Color(0x0B, 0x1B, 0x2B);
    private static final Color MUTED = new Color(0x5B, 0x6B, 0x7B);
    private static final Color HEADER = new Color(0xE6, 0xF4, 0xF3);

    private final Clock clock;

    ComplianceReport(Clock clock) {
        this.clock = clock;
    }

    @SuppressWarnings("unchecked")
    byte[] render(Map<String, Object> d, boolean en) {
        Font title = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, INK);
        Font h2 = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, INK);
        Font body = FontFactory.getFont(FontFactory.HELVETICA, 10, INK);
        Font muted = FontFactory.getFont(FontFactory.HELVETICA, 9, MUTED);
        Font th = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, INK);

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4, 48, 48, 54, 54);
        PdfWriter.getInstance(doc, out);
        doc.addTitle(en ? "Security awareness report" : "Nachweis Security-Awareness");
        doc.open();

        doc.add(new Paragraph("KÖDER", muted));
        doc.add(new Paragraph(en ? "Security awareness report" : "Nachweis Security-Awareness", title));
        doc.add(spaced(String.valueOf(d.get("name")) + " · " + LocalDate.now(clock), body, 4, 16));
        if (Boolean.TRUE.equals(d.get("demoData"))) {
            doc.add(spaced(en ? "Demo company: all figures are synthetic." : "Demo-Unternehmen: alle Zahlen sind synthetisch.", muted, 0, 12));
        }

        doc.add(spaced(en ? "Key figures (last 10 weeks)" : "Kennzahlen (letzte 10 Wochen)", h2, 6, 6));
        PdfPTable kpis = table(new float[]{3, 1});
        row(kpis, body, en ? "Human Risk Score (0 = low risk, 100 = high risk)" : "Human Risk Score (0 = geringes, 100 = hohes Risiko)", val(d.get("risk"), ""));
        row(kpis, body, en ? "Reporting rate: attacks reported to IT" : "Melderate: an die IT gemeldete Angriffe", val(d.get("reportingRate"), " %"));
        row(kpis, body, en ? "Click rate: attacks that succeeded" : "Klickrate: erfolgreiche Angriffe", val(d.get("clickRate"), " %"));
        row(kpis, body, en ? "Training decisions recorded" : "Erfasste Trainingsentscheidungen", val(d.get("answers"), ""));
        doc.add(kpis);

        doc.add(spaced(en ? "Departments" : "Abteilungen", h2, 16, 6));
        PdfPTable table = table(new float[]{3, 1, 1, 1, 1});
        for (String col : en ? List.of("Department", "Size", "Risk", "Reporting", "Clicks") : List.of("Abteilung", "Größe", "Risiko", "Melderate", "Klickrate")) {
            PdfPCell c = new PdfPCell(new Phrase(col, th));
            c.setBackgroundColor(HEADER);
            c.setPadding(6);
            c.setBorderColor(Color.LIGHT_GRAY);
            table.addCell(c);
        }
        for (Map<String, Object> dep : (List<Map<String, Object>>) d.get("departments")) {
            boolean hidden = Boolean.TRUE.equals(dep.get("hidden"));
            String na = en ? "hidden" : "verborgen";
            row(table, body, String.valueOf(dep.get("name")), String.valueOf(dep.get("headcount")),
                    hidden ? na : val(dep.get("risk"), ""),
                    hidden ? na : val(dep.get("reportingRate"), " %"),
                    hidden ? na : val(dep.get("clickRate"), " %"));
        }
        doc.add(table);

        doc.add(spaced(en
                ? "Data protection: this report contains only aggregated figures. Departments with fewer than %d people show no figures. Statistics are stored without any reference to a person, so individual results cannot be reconstructed from them."
                .formatted(d.get("minDepartmentSize"))
                : "Datenschutz: Dieser Bericht enthält ausschließlich aggregierte Zahlen. Abteilungen mit weniger als %d Personen werden nicht ausgewiesen. Die Statistik wird ohne Personenbezug gespeichert, einzelne Ergebnisse lassen sich daraus nicht rekonstruieren."
                .formatted(d.get("minDepartmentSize")), muted, 16, 8));
        doc.add(spaced(en
                ? "Supports evidence for: NIS2 Art. 20 (training), ISO/IEC 27001 Annex A 6.3 (awareness), TISAX. This report does not replace an assessment by an auditor."
                : "Unterstützt den Nachweis für: NIS2 Art. 20 (Schulung), ISO/IEC 27001 Anhang A 6.3 (Awareness), TISAX. Dieser Bericht ersetzt keine Prüfung durch Auditoren.", muted, 0, 0));
        doc.close();
        return out.toByteArray();
    }

    private static String val(Object v, String suffix) {
        return v == null ? "–" : v + suffix;
    }

    private static PdfPTable table(float[] widths) {
        PdfPTable t = new PdfPTable(widths);
        t.setWidthPercentage(100);
        return t;
    }

    private static void row(PdfPTable t, Font f, String... cells) {
        for (int i = 0; i < cells.length; i++) {
            PdfPCell c = new PdfPCell(new Phrase(cells[i], f));
            c.setPadding(6);
            c.setBorderColor(Color.LIGHT_GRAY);
            if (i > 0) {
                c.setHorizontalAlignment(Element.ALIGN_RIGHT);
            }
            t.addCell(c);
        }
    }

    private static Paragraph spaced(String text, Font f, float before, float after) {
        Paragraph p = new Paragraph(text, f);
        p.setSpacingBefore(before);
        p.setSpacingAfter(after);
        return p;
    }
}
