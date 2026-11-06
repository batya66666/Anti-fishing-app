package de.koeder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;

/** Walks through the real HTTP API against real Postgres, the way the app does. */
class GameFlowIntegrationTest extends IntegrationTestBase {

    @LocalServerPort
    int port;

    @Value("${koeder.demo.manager-email}")
    String managerEmail;

    @Value("${koeder.demo.manager-password}")
    String managerPassword;

    private RestClient client(String token) {
        var builder = RestClient.builder().baseUrl("http://localhost:" + port)
                .defaultStatusHandler(HttpStatusCode::isError, (req, res) -> {
                });
        if (token != null) {
            builder.defaultHeader("Authorization", "Bearer " + token);
        }
        return builder.build();
    }

    @SuppressWarnings("unchecked")
    private String guest() {
        Map<String, Object> r = client(null).post().uri("/api/auth/guest").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("deviceId", UUID.randomUUID().toString(), "locale", "de")).retrieve().body(Map.class);
        return (String) r.get("token");
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> get(String token, String path) {
        return client(token).get().uri(path).retrieve().body(Map.class);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> act(String token, String shiftId, String scenarioId, String action) {
        return client(token).post().uri("/api/shifts/" + shiftId + "/actions").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("scenarioId", scenarioId, "action", action, "ms", 3000)).retrieve().body(Map.class);
    }

    @Test
    void theApiIsClosedWithoutAToken() {
        assertThat(client(null).get().uri("/api/me").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(401);
    }

    @Test
    @SuppressWarnings("unchecked")
    void aFullShiftEarnsProgressAndNeverLeaksTheSolution() {
        String token = guest();
        Map<String, Object> shift = get(token, "/api/shifts/today");
        List<Map<String, Object>> scenarios = (List<Map<String, Object>>) shift.get("scenarios");
        assertThat(scenarios).hasSize(8);

        // Anti-cheat: nothing in the shift payload may reveal the answer.
        String raw = client(token).get().uri("/api/shifts/today").retrieve().body(String.class);
        assertThat(raw).doesNotContain("is_attack", "isAttack", "correct_actions", "correctActions", "red_flags", "redFlags", "explanation");

        String shiftId = (String) shift.get("id");
        // The curated first shift contains the invoice with the .exe. Opening it is the demo moment.
        Map<String, Object> hacked = act(token, shiftId, "mail-invoice-exe", "open_attachment");
        Map<String, Object> evaluation = (Map<String, Object>) hacked.get("evaluation");
        assertThat(evaluation.get("outcome")).isEqualTo("HACKED");
        assertThat((List<?>) evaluation.get("redFlags")).hasSize(3);

        Map<String, Object> report = act(token, shiftId, "sms-parcel", "report");
        assertThat(((Map<String, Object>) report.get("evaluation")).get("outcome")).isEqualTo("CORRECT");

        // A second answer to the same message is rejected: no XP farming.
        var again = client(token).post().uri("/api/shifts/" + shiftId + "/actions").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("scenarioId", "sms-parcel", "action", "report", "ms", 1)).retrieve().toBodilessEntity();
        assertThat(again.getStatusCode().value()).isEqualTo(409);

        Map<String, Object> last = null;
        for (Map<String, Object> s : scenarios) {
            String id = (String) s.get("id");
            if (!id.equals("mail-invoice-exe") && !id.equals("sms-parcel")) {
                last = act(token, shiftId, id, "report");
            }
        }
        assertThat(last.get("shiftCompleted")).isEqualTo(true);

        Map<String, Object> me = get(token, "/api/me");
        assertThat((Integer) me.get("xp")).isPositive();
        assertThat(me.get("streak")).isEqualTo(1);
        assertThat(me.get("shiftsDone")).isEqualTo(1);
        assertThat(me.get("timesHacked")).isEqualTo(1);
        assertThat((Integer) me.get("attacksReported")).isPositive();
        assertThat((List<String>) me.get("badges")).contains("first_shift", "first_report", "learned_the_hard_way");
        assertThat(((Map<String, Object>) me.get("energy")).get("shiftCompleted")).isEqualTo(true);
    }

    @Test
    void aForeignScenarioIsRefused() {
        String token = guest();
        Map<String, Object> shift = get(token, "/api/shifts/today");
        var response = client(token).post().uri("/api/shifts/" + shift.get("id") + "/actions").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("scenarioId", "does-not-exist", "action", "report", "ms", 1)).retrieve().toBodilessEntity();
        assertThat(response.getStatusCode().value()).isEqualTo(400);
    }

    @Test
    void oneUserCannotTouchAnotherUsersShift() {
        Map<String, Object> shift = get(guest(), "/api/shifts/today");
        var response = client(guest()).post().uri("/api/shifts/" + shift.get("id") + "/actions").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("scenarioId", "sms-parcel", "action", "report", "ms", 1)).retrieve().toBodilessEntity();
        assertThat(response.getStatusCode().value()).isEqualTo(404);
    }

    @Test
    void swipeRoundsAreLimitedPerDay() {
        String token = guest();
        for (int i = 0; i < 3; i++) {
            assertThat(client(token).get().uri("/api/swipe/deck").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(200);
        }
        assertThat(client(token).get().uri("/api/swipe/deck").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(429);
    }

    @Test
    @SuppressWarnings("unchecked")
    void reviewQueueAlwaysRemainsFreeAndCollectsMistakes() {
        String token = guest();
        Map<String, Object> shift = get(token, "/api/shifts/today");
        act(token, (String) shift.get("id"), "mail-invoice-exe", "open_attachment");
        // Due tomorrow, not now: then the demo reset makes it due at once.
        assertThat(((Number) get(token, "/api/me").get("reviewsDue")).intValue()).isZero();
        client(token).post().uri("/api/me/demo-reset").retrieve().toBodilessEntity();
        assertThat(((Number) get(token, "/api/me").get("reviewsDue")).intValue()).isEqualTo(1);
    }

    @Test
    void anEmployeeCannotSeeTheCompanyDashboard() {
        String token = guest();
        String org = (String) get(token, "/api/me").get("orgId");
        assertThat(org).isNotNull();
        assertThat(client(token).get().uri("/api/orgs/" + org + "/dashboard").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(403);
    }

    private String manager() {
        @SuppressWarnings("unchecked")
        Map<String, Object> r = client(null).post().uri("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("email", managerEmail, "password", managerPassword)).retrieve().body(Map.class);
        return (String) r.get("token");
    }

    @Test
    void aManagerOfAnotherCompanyIsRefused() {
        String token = manager();
        assertThat(client(token).get().uri("/api/orgs/" + UUID.randomUUID() + "/dashboard").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(403);
    }

    @Test
    void aWrongPasswordIsRefused() {
        var response = client(null).post().uri("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("email", managerEmail, "password", "wrong-password")).retrieve().toBodilessEntity();
        assertThat(response.getStatusCode().value()).isEqualTo(401);
    }

    @Test
    @SuppressWarnings("unchecked")
    void theDashboardIsAggregatedAndHidesSmallDepartments() {
        String token = manager();
        String org = (String) get(token, "/api/me").get("orgId");
        Map<String, Object> d = get(token, "/api/orgs/" + org + "/dashboard");

        assertThat((Integer) d.get("risk")).isBetween(0, 100);
        List<Map<String, Object>> departments = (List<Map<String, Object>>) d.get("departments");
        Map<String, Object> management = departments.stream().filter(x -> "Geschäftsführung".equals(x.get("name"))).findFirst().orElseThrow();
        assertThat(management.get("hidden")).isEqualTo(true);
        assertThat(management).doesNotContainKeys("risk", "reportingRate", "clickRate");
        List<Map<String, Object>> cells = (List<Map<String, Object>>) d.get("heatmap");
        assertThat(cells).isNotEmpty().noneMatch(c -> management.get("id").equals(c.get("departmentId")));

        // Privacy by design: the whole payload has no user ids, and nothing resembles a person.
        String raw = client(token).get().uri("/api/orgs/" + org + "/dashboard").retrieve().body(String.class);
        assertThat(raw).doesNotContain("userId", "displayName", "email");
    }

    @Test
    @SuppressWarnings("unchecked")
    void answersOfAnEmployeeMoveTheDashboardWithoutNamingThem() {
        String manager = manager();
        String org = (String) get(manager, "/api/me").get("orgId");
        long before = ((Number) get(manager, "/api/orgs/" + org + "/dashboard").get("answers")).longValue();

        String employee = guest();
        Map<String, Object> shift = get(employee, "/api/shifts/today");
        act(employee, (String) shift.get("id"), "sms-parcel", "report");

        await().atMost(Duration.ofSeconds(5)).untilAsserted(() -> {
            Map<String, Object> d = get(manager, "/api/orgs/" + org + "/dashboard");
            assertThat(((Number) d.get("answers")).longValue()).isGreaterThan(before);
            assertThat((List<Map<String, Object>>) d.get("feed")).anyMatch(f -> "reported".equals(f.get("kind")));
        });
    }

    @Test
    void complianceReportIsAPdf() {
        String token = manager();
        String org = (String) get(token, "/api/me").get("orgId");
        byte[] pdf = client(token).get().uri("/api/orgs/" + org + "/reports/compliance.pdf").retrieve().body(byte[].class);
        assertThat(new String(pdf, 0, 5, java.nio.charset.StandardCharsets.ISO_8859_1)).isEqualTo("%PDF-");
    }

    @Test
    @SuppressWarnings("unchecked")
    void scenarioGenerationCreatesDraftsThatOnlyGoLiveAfterReview() {
        String token = manager();
        String org = (String) get(token, "/api/me").get("orgId");
        Map<String, Object> result = client(token).post().uri("/api/orgs/" + org + "/scenarios/generate").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("companyName", "Testwerk GmbH", "industry", "Automotive", "tools", "SAP", "partners", "Kessler Stahl", "employees", 300, "count", 4, "locale", "de"))
                .retrieve().body(Map.class);
        assertThat(result.get("source")).isEqualTo("template"); // no API key in tests, and the API says so honestly
        List<Map<String, Object>> scenarios = (List<Map<String, Object>>) result.get("scenarios");
        assertThat(scenarios).hasSize(4);

        String employee = guest();
        Map<String, Object> shift = get(employee, "/api/shifts/today");
        assertThat(shift.toString()).doesNotContain("Testwerk");

        String id = (String) scenarios.get(0).get("id");
        assertThat(client(token).post().uri("/api/orgs/" + org + "/scenarios/" + id + "/publish").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(200);
        assertThat(client(token).get().uri("/api/orgs/" + org + "/scenarios").retrieve().body(String.class)).contains("Testwerk");
    }

    @Test
    void messageCheckWorksWithoutAnApiKey() {
        @SuppressWarnings("unchecked")
        Map<String, Object> r = client(guest()).post().uri("/api/ai/check-message").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("text", "Ihr Konto wird gesperrt. Passwort sofort bestätigen: bank-login.xyz", "locale", "de")).retrieve().body(Map.class);
        assertThat(r.get("verdict")).isEqualTo("dangerous");
        assertThat(r.get("source")).isEqualTo("rules");
    }

    @Test
    void deletingAnAccountRemovesEverything() {
        String token = guest();
        Map<String, Object> shift = get(token, "/api/shifts/today");
        act(token, (String) shift.get("id"), "sms-parcel", "report");
        assertThat(client(token).get().uri("/api/me/export").retrieve().body(String.class)).contains("sms-parcel");
        assertThat(client(token).delete().uri("/api/me").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(204);
        assertThat(client(token).get().uri("/api/me").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(401);
    }

    @Test
    void swaggerAndHealthArePublic() {
        assertThat(client(null).get().uri("/actuator/health").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(200);
        assertThat(client(null).get().uri("/v3/api-docs").retrieve().body(String.class)).contains("/api/shifts/today");
    }
}
