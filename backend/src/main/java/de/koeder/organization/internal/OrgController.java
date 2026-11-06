package de.koeder.organization.internal;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import de.koeder.ai.AiApi;
import de.koeder.content.Scenario;
import de.koeder.content.ScenarioCatalog;
import de.koeder.identity.CurrentUser;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Everything here is aggregate data for company managers. There is no endpoint that returns a person. */
@RestController
@RequestMapping("/api/orgs")
@Tag(name = "organization")
class OrgController {

    private final OrgService orgs;
    private final ComplianceReport report;
    private final AiApi ai;
    private final ScenarioCatalog catalog;

    OrgController(OrgService orgs, ComplianceReport report, AiApi ai, ScenarioCatalog catalog) {
        this.orgs = orgs;
        this.report = report;
        this.ai = ai;
        this.catalog = catalog;
    }

    record GenerateRequest(@NotBlank @Size(max = 120) String companyName,
                           @Size(max = 120) String industry,
                           @Size(max = 300) String tools,
                           @Size(max = 300) String partners,
                           @Min(1) @Max(100000) int employees,
                           @Min(1) @Max(12) int count,
                           String locale) {
    }

    record GeneratedResponse(List<Scenario> scenarios, String source) {
    }

    record JoinRequest(@NotBlank @Size(max = 20) String code) {
    }

    @PostMapping("/join")
    void join(@Valid @RequestBody JoinRequest r) {
        orgs.joinByCode(CurrentUser.id(), r.code());
    }

    @GetMapping("/{id}/dashboard")
    @PreAuthorize("hasAnyRole('MANAGER','ADMIN')")
    Map<String, Object> dashboard(@PathVariable UUID id) {
        orgs.requireManagerOf(CurrentUser.id(), id);
        return orgs.dashboardData(id);
    }

    @GetMapping("/{id}/scenarios")
    @PreAuthorize("hasAnyRole('MANAGER','ADMIN')")
    List<Scenario> scenarios(@PathVariable UUID id) {
        orgs.requireManagerOf(CurrentUser.id(), id);
        return catalog.orgScenarios(id, true);
    }

    @PostMapping("/{id}/scenarios")
    @PreAuthorize("hasAnyRole('MANAGER','ADMIN')")
    Scenario addScenario(@PathVariable UUID id, @RequestBody Scenario scenario) {
        orgs.requireManagerOf(CurrentUser.id(), id);
        return catalog.saveOrgScenario(id, scenario, true);
    }

    /** Generated scenarios arrive as drafts. A human reviews and publishes them before anyone plays them. */
    @PostMapping("/{id}/scenarios/generate")
    @PreAuthorize("hasAnyRole('MANAGER','ADMIN')")
    GeneratedResponse generate(@PathVariable UUID id, @Valid @RequestBody GenerateRequest r) {
        orgs.requireManagerOf(CurrentUser.id(), id);
        String locale = "en".equals(r.locale()) ? "en" : "de";
        var result = ai.generateScenarios(new AiApi.CompanyProfile(r.companyName(), r.industry(), r.tools(), r.partners(), r.employees()), r.count(), locale);
        List<Scenario> stored = new ArrayList<>();
        for (Scenario s : result.scenarios()) {
            stored.add(catalog.saveOrgScenario(id, s, false));
        }
        return new GeneratedResponse(stored, result.source());
    }

    @PostMapping("/{id}/scenarios/{scenarioId}/publish")
    @PreAuthorize("hasAnyRole('MANAGER','ADMIN')")
    void publish(@PathVariable UUID id, @PathVariable String scenarioId) {
        orgs.requireManagerOf(CurrentUser.id(), id);
        catalog.publish(id, scenarioId);
    }

    @GetMapping(value = "/{id}/reports/compliance.pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    @PreAuthorize("hasAnyRole('MANAGER','ADMIN')")
    ResponseEntity<byte[]> compliance(@PathVariable UUID id, @RequestParam(defaultValue = "de") String locale) {
        orgs.requireManagerOf(CurrentUser.id(), id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"koeder-compliance.pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(report.render(orgs.dashboardData(id), "en".equals(locale)));
    }
}
