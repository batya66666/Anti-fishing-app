package de.koeder.organization.internal;

import java.sql.Date;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.modulith.events.ApplicationModuleListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import de.koeder.identity.IdentityApi;
import de.koeder.identity.UserRef;
import de.koeder.identity.UserRegistered;
import de.koeder.shift.ScenarioAnswered;

/**
 * Company analytics. By design this module keeps no per-person data: an answer becomes
 * a counter on department + day + attack type, and the user id is dropped right here.
 */
@Service
class OrgService {

    /** A department below this size shows no numbers: individuals must not be identifiable. */
    static final int MIN_DEPARTMENT_SIZE = 5;
    private static final String DEMO_CODE = "DEMO";

    private final JdbcClient jdbc;
    private final IdentityApi identity;
    private final SimpMessagingTemplate broker;
    private final Clock clock;
    private final boolean demoEnabled;
    private final boolean autoJoin;
    private final String managerEmail;
    private final String managerPassword;
    private final Map<UUID, Deque<Map<String, Object>>> feeds = new ConcurrentHashMap<>();

    OrgService(JdbcClient jdbc, IdentityApi identity, SimpMessagingTemplate broker, Clock clock,
               @Value("${koeder.demo.enabled}") boolean demoEnabled,
               @Value("${koeder.demo.auto-join}") boolean autoJoin,
               @Value("${koeder.demo.manager-email}") String managerEmail,
               @Value("${koeder.demo.manager-password}") String managerPassword) {
        this.jdbc = jdbc;
        this.identity = identity;
        this.broker = broker;
        this.clock = clock;
        this.demoEnabled = demoEnabled;
        this.autoJoin = autoJoin;
        this.managerEmail = managerEmail;
        this.managerPassword = managerPassword;
    }

    // ------------------------------------------------------------------ demo company

    @EventListener(ApplicationReadyEvent.class)
    @Order(10)
    @Transactional
    public void seedDemo() {
        if (!demoEnabled) {
            return;
        }
        UUID existing = jdbc.sql("SELECT id FROM organizations WHERE join_code = :c").param("c", DEMO_CODE).query(UUID.class).optional().orElse(null);
        if (existing != null) {
            identity.ensureManager(managerEmail, managerPassword, "Thomas Berger", existing);
            return;
        }
        UUID org = UUID.randomUUID();
        jdbc.sql("""
                INSERT INTO organizations (id, name, industry, plan, seats, join_code, is_demo)
                VALUES (:id, 'Muster Automotive GmbH', 'Automobilzulieferer', 'business', 300, :c, true)
                """).param("id", org).param("c", DEMO_CODE).update();
        identity.ensureManager(managerEmail, managerPassword, "Thomas Berger", org);

        // Synthetic history for the dashboard, reproducible thanks to the fixed seed. Each profile tells a story:
        // accounting is weak on invoices, sales on links, management is too small to show at all.
        Map<String, double[]> departments = new LinkedHashMap<>();
        departments.put("Buchhaltung", new double[]{18, 0.34, 0.30});
        departments.put("Einkauf", new double[]{14, 0.26, 0.38});
        departments.put("Vertrieb", new double[]{26, 0.30, 0.34});
        departments.put("Personal", new double[]{9, 0.22, 0.44});
        departments.put("Produktion", new double[]{64, 0.24, 0.28});
        departments.put("IT", new double[]{12, 0.06, 0.86});
        departments.put("Geschäftsführung", new double[]{3, 0.20, 0.50});

        Map<String, Map<String, Double>> weakness = Map.of(
                "Buchhaltung", Map.of("invoice_fraud", 2.1, "ceo_fraud", 1.7),
                "Einkauf", Map.of("invoice_fraud", 1.6),
                "Vertrieb", Map.of("credential_phishing", 1.9, "smishing", 1.5),
                "Personal", Map.of("malicious_attachment", 2.0),
                "Produktion", Map.of("quishing", 1.9, "usb_drop", 1.7),
                "IT", Map.of("vishing", 2.2));

        List<String> types = List.of("invoice_fraud", "credential_phishing", "ceo_fraud", "malicious_attachment", "smishing", "vishing", "quishing", "mfa_fatigue");
        Random random = new Random(20261106L);
        LocalDate today = LocalDate.now(clock);
        int weeks = 10;
        for (var dep : departments.entrySet()) {
            UUID depId = UUID.randomUUID();
            int headcount = (int) dep.getValue()[0];
            jdbc.sql("INSERT INTO departments (id, org_id, name, headcount) VALUES (:id, :o, :n, :h)")
                    .param("id", depId).param("o", org).param("n", dep.getKey()).param("h", headcount).update();
            double click = dep.getValue()[1];
            double report = dep.getValue()[2];
            Map<String, Double> weak = weakness.getOrDefault(dep.getKey(), Map.of());
            for (int w = weeks; w >= 0; w--) {
                // Training works: rates improve over the ten weeks shown.
                double progress = (weeks - w) / (double) weeks;
                LocalDate day = today.minusWeeks(w).with(TemporalAdjusters.previousOrSame(DayOfWeek.WEDNESDAY));
                for (String type : types) {
                    double typeClick = Math.min(0.9, click * weak.getOrDefault(type, 1.0) * (1 - 0.55 * progress));
                    double typeReport = Math.min(0.97, report + (1 - report) * 0.5 * progress);
                    int attacks = Math.max(2, (int) Math.round(headcount * 0.35 + random.nextInt(4)));
                    int hacked = binomial(random, attacks, typeClick);
                    int reported = binomial(random, attacks - hacked, typeReport);
                    insertStats(org, depId, day, type, attacks, attacks - hacked, hacked, reported, attacks, 0);
                }
                int legit = Math.max(4, (int) Math.round(headcount * 1.2));
                int alarms = binomial(random, legit, 0.09 * (1 - 0.4 * progress));
                insertStats(org, depId, day, "legit", legit, legit - alarms, 0, 0, 0, alarms);
            }
        }
    }

    private static int binomial(Random r, int n, double p) {
        int hits = 0;
        for (int i = 0; i < n; i++) {
            if (r.nextDouble() < p) {
                hits++;
            }
        }
        return hits;
    }

    private void insertStats(UUID org, UUID dep, LocalDate day, String type, int answers, int correct, int hacked, int reported, int attacks, int falseAlarms) {
        jdbc.sql("""
                INSERT INTO org_stats (org_id, department_id, day, attack_type, answers, correct, hacked, reported, attacks, false_alarms)
                VALUES (:o, :d, :day, :t, :a, :c, :h, :r, :at, :f)
                ON CONFLICT (department_id, day, attack_type) DO UPDATE SET
                  answers = org_stats.answers + :a, correct = org_stats.correct + :c, hacked = org_stats.hacked + :h,
                  reported = org_stats.reported + :r, attacks = org_stats.attacks + :at, false_alarms = org_stats.false_alarms + :f
                """).param("o", org).param("d", dep).param("day", Date.valueOf(day)).param("t", type)
                .param("a", answers).param("c", correct).param("h", hacked).param("r", reported).param("at", attacks).param("f", falseAlarms)
                .update();
    }

    /** In the demo every new guest joins the demo company, so the jury's answers move the dashboard live. */
    @EventListener
    @Transactional
    public void on(UserRegistered e) {
        if (demoEnabled && autoJoin) {
            jdbc.sql("SELECT id FROM organizations WHERE join_code = :c").param("c", DEMO_CODE).query(UUID.class).optional()
                    .ifPresent(org -> joinInternal(e.userId(), org));
        }
    }

    private void joinInternal(UUID userId, UUID org) {
        List<UUID> departments = jdbc.sql("SELECT id FROM departments WHERE org_id = :o AND headcount >= :min ORDER BY name")
                .param("o", org).param("min", MIN_DEPARTMENT_SIZE).query(UUID.class).list();
        if (departments.isEmpty()) {
            return;
        }
        UUID dep = departments.get(ThreadLocalRandom.current().nextInt(departments.size()));
        int inserted = jdbc.sql("INSERT INTO memberships (user_id, org_id, department_id) VALUES (:u, :o, :d) ON CONFLICT DO NOTHING")
                .param("u", userId).param("o", org).param("d", dep).update();
        if (inserted > 0) {
            jdbc.sql("UPDATE departments SET headcount = headcount + 1 WHERE id = :d").param("d", dep).update();
            identity.assignOrg(userId, org);
        }
    }

    @Transactional
    void joinByCode(UUID userId, String code) {
        UUID org = jdbc.sql("SELECT id FROM organizations WHERE join_code = :c").param("c", code.strip().toUpperCase()).query(UUID.class)
                .optional().orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "unknown company code"));
        joinInternal(userId, org);
    }

    // ------------------------------------------------------------------ live statistics

    /** Asynchronous and after commit: a slow dashboard broadcast can never slow down or fail a player's answer. */
    @ApplicationModuleListener
    public void on(ScenarioAnswered e) {
        var membership = jdbc.sql("""
                SELECT m.org_id, m.department_id, d.name FROM memberships m JOIN departments d ON d.id = m.department_id WHERE m.user_id = :u
                """).param("u", e.userId())
                .query((rs, n) -> new Object[]{rs.getObject(1, UUID.class), rs.getObject(2, UUID.class), rs.getString(3)})
                .optional();
        if (membership.isEmpty()) {
            return;
        }
        UUID org = (UUID) membership.get()[0];
        UUID dep = (UUID) membership.get()[1];
        String depName = (String) membership.get()[2];
        boolean hacked = "HACKED".equals(e.outcome());
        insertStats(org, dep, LocalDate.now(clock), e.bucket(), 1, e.correct() ? 1 : 0, hacked ? 1 : 0, e.reported() ? 1 : 0,
                e.attack() ? 1 : 0, "FALSE_ALARM".equals(e.outcome()) ? 1 : 0);

        // The feed names the department, never the person.
        String kind = e.reported() ? "reported" : (hacked ? "hacked" : (e.correct() ? "handled" : "missed"));
        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("department", depName);
        entry.put("kind", kind);
        entry.put("attackType", e.bucket());
        entry.put("at", clock.instant().toString());
        Deque<Map<String, Object>> feed = feeds.computeIfAbsent(org, k -> new ArrayDeque<>());
        synchronized (feed) {
            feed.addFirst(entry);
            while (feed.size() > 12) {
                feed.removeLast();
            }
        }
        broker.convertAndSend("/topic/org/" + org + "/live", (Object) dashboardData(org));
    }

    // ------------------------------------------------------------------ dashboard

    /** The caller must be a manager of exactly this company. Backs up @PreAuthorize on the endpoints. */
    void requireManagerOf(UUID userId, UUID orgId) {
        UserRef u = identity.require(userId);
        boolean manager = "MANAGER".equals(u.role()) || "ADMIN".equals(u.role());
        if (!manager || u.orgId() == null || !u.orgId().equals(orgId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
    }

    private record DepAgg(UUID id, String name, int headcount, long answers, long attacks, long hacked, long reported, long falseAlarms) {
    }

    @Transactional(readOnly = true)
    public Map<String, Object> dashboardData(UUID org) {
        Map<String, Object> o = jdbc.sql("SELECT name, industry, plan, seats, is_demo FROM organizations WHERE id = :o").param("o", org).query().singleRow();
        LocalDate since = LocalDate.now(clock).minusWeeks(10);

        List<DepAgg> deps = jdbc.sql("""
                SELECT d.id, d.name, d.headcount, coalesce(sum(s.answers),0) answers, coalesce(sum(s.attacks),0) attacks,
                       coalesce(sum(s.hacked),0) hacked, coalesce(sum(s.reported),0) reported, coalesce(sum(s.false_alarms),0) fa
                FROM departments d LEFT JOIN org_stats s ON s.department_id = d.id AND s.day >= :since
                WHERE d.org_id = :o GROUP BY d.id, d.name, d.headcount ORDER BY d.name
                """).param("o", org).param("since", Date.valueOf(since))
                .query((rs, n) -> new DepAgg(rs.getObject(1, UUID.class), rs.getString(2), rs.getInt(3), rs.getLong(4), rs.getLong(5), rs.getLong(6), rs.getLong(7), rs.getLong(8)))
                .list();

        long answers = 0, attacks = 0, hacked = 0, reported = 0, falseAlarms = 0;
        List<Map<String, Object>> departmentRows = new ArrayList<>();
        for (DepAgg d : deps) {
            answers += d.answers;
            attacks += d.attacks;
            hacked += d.hacked;
            reported += d.reported;
            falseAlarms += d.falseAlarms;
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id", d.id.toString());
            row.put("name", d.name);
            row.put("headcount", d.headcount);
            boolean hidden = d.headcount < MIN_DEPARTMENT_SIZE;
            row.put("hidden", hidden);
            if (!hidden) {
                putIfNotNull(row, "risk", RiskScore.of(d.answers, d.attacks, d.hacked, d.reported, d.falseAlarms));
                putIfNotNull(row, "reportingRate", RiskScore.rate(d.reported, d.attacks));
                putIfNotNull(row, "clickRate", RiskScore.rate(d.hacked, d.attacks));
            }
            departmentRows.add(row);
        }

        List<Map<String, Object>> cells = jdbc.sql("""
                SELECT s.department_id, s.attack_type, sum(s.answers) answers, sum(s.attacks) attacks, sum(s.hacked) hacked, sum(s.reported) reported
                FROM org_stats s JOIN departments d ON d.id = s.department_id
                WHERE s.org_id = :o AND s.day >= :since AND s.attack_type <> 'legit' AND d.headcount >= :min
                GROUP BY s.department_id, s.attack_type
                """).param("o", org).param("since", Date.valueOf(since)).param("min", MIN_DEPARTMENT_SIZE)
                .query((rs, n) -> {
                    Map<String, Object> c = new LinkedHashMap<>();
                    c.put("departmentId", rs.getObject(1, UUID.class).toString());
                    c.put("attackType", rs.getString(2));
                    putIfNotNull(c, "risk", RiskScore.of(rs.getLong(3), rs.getLong(4), rs.getLong(5), rs.getLong(6), 0));
                    return c;
                }).list();

        LocalDate trendStart = LocalDate.now(clock).minusWeeks(10).with(DayOfWeek.MONDAY);
        List<Map<String, Object>> trend = jdbc.sql("""
                SELECT date_trunc('week', s.day)::date wk, sum(s.answers) answers, sum(s.attacks) attacks, sum(s.hacked) hacked,
                       sum(s.reported) reported, sum(s.false_alarms) fa
                FROM org_stats s WHERE s.org_id = :o AND s.day >= :since GROUP BY wk ORDER BY wk
                """).param("o", org).param("since", Date.valueOf(trendStart))
                .query((rs, n) -> {
                    Map<String, Object> t = new LinkedHashMap<>();
                    t.put("week", rs.getDate(1).toString());
                    putIfNotNull(t, "risk", RiskScore.of(rs.getLong(2), rs.getLong(3), rs.getLong(4), rs.getLong(5), rs.getLong(6)));
                    putIfNotNull(t, "reportingRate", RiskScore.rate(rs.getLong(5), rs.getLong(3)));
                    return t;
                }).list();

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("orgId", org.toString());
        out.put("name", o.get("name"));
        out.put("industry", o.get("industry"));
        out.put("plan", o.get("plan"));
        out.put("seats", o.get("seats"));
        out.put("demoData", o.get("is_demo"));
        putIfNotNull(out, "risk", RiskScore.of(answers, attacks, hacked, reported, falseAlarms));
        putIfNotNull(out, "reportingRate", RiskScore.rate(reported, attacks));
        putIfNotNull(out, "clickRate", RiskScore.rate(hacked, attacks));
        out.put("answers", answers);
        out.put("minDepartmentSize", MIN_DEPARTMENT_SIZE);
        out.put("departments", departmentRows);
        out.put("heatmap", cells);
        out.put("trend", trend);
        Deque<Map<String, Object>> feed = feeds.get(org);
        if (feed != null) {
            synchronized (feed) {
                out.put("feed", List.copyOf(feed));
            }
        } else {
            out.put("feed", List.of());
        }
        return out;
    }

    private static void putIfNotNull(Map<String, Object> m, String key, Object value) {
        if (value != null) {
            m.put(key, value);
        }
    }
}
