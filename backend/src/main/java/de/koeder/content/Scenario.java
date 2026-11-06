package de.koeder.content;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Full scenario including the solution. Never leaves the server as-is: clients get {@link PublicScenario}. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record Scenario(
        String id,
        String type,
        String locale,
        String difficulty,
        @JsonProperty("is_attack") boolean attack,
        @JsonProperty("attack_type") String attackType,
        int module,
        boolean consumer,
        Map<String, Object> content,
        @JsonProperty("red_flags") List<RedFlag> redFlags,
        @JsonProperty("correct_actions") List<String> correctActions,
        @JsonProperty("dangerous_actions") List<String> dangerousActions,
        String explanation,
        List<String> tags,
        UUID orgId) {

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record RedFlag(String target, String hint) {
    }

    public PublicScenario toPublic() {
        return new PublicScenario(id, type, locale, difficulty, module, content);
    }

    /** Analytics bucket: legitimate messages count under their own category. */
    public String statsBucket() {
        return attack ? attackType : "legit";
    }

    public Scenario withOrg(UUID org) {
        return new Scenario(id, type, locale, difficulty, attack, attackType, module, consumer, content, redFlags,
                correctActions, dangerousActions, explanation, tags, org);
    }
}
