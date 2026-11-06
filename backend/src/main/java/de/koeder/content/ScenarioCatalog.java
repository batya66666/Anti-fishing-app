package de.koeder.content;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Read access to scenarios for the other modules. */
public interface ScenarioCatalog {

    Optional<Scenario> find(String id, String locale);

    /** Public scenarios of a locale plus the published pack of the given company. */
    List<Scenario> pool(String locale, UUID orgId);

    /** Validates against the JSON Schema and stores a company scenario. */
    Scenario saveOrgScenario(UUID orgId, Scenario scenario, boolean published);

    List<Scenario> orgScenarios(UUID orgId, boolean includeDrafts);

    void publish(UUID orgId, String scenarioId);
}
