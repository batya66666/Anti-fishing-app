package de.koeder.content.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;

/** Broken content fails CI, not the demo. Also guards the content rules from the spec. */
class ScenarioSchemaTest {

    private static final ObjectMapper JSON = JsonMapper.builder().build();
    private static final Pattern DOMAIN = Pattern.compile("(?i)https?://([a-z0-9.-]+)");
    private static final Map<String, List<JsonNode>> BY_LOCALE = new HashMap<>();

    @BeforeAll
    static void load() throws IOException {
        for (Resource r : new PathMatchingResourcePatternResolver().getResources("classpath*:content/scenarios/*/*.json")) {
            for (JsonNode node : JSON.readTree(r.getContentAsString(StandardCharsets.UTF_8))) {
                BY_LOCALE.computeIfAbsent(node.path("locale").asString(), k -> new ArrayList<>()).add(node);
            }
        }
    }

    private static List<JsonNode> all() {
        return BY_LOCALE.values().stream().flatMap(List::stream).toList();
    }

    @Test
    void everyScenarioMatchesTheSchema() {
        ScenarioValidator validator = new ScenarioValidator();
        List<String> problems = new ArrayList<>();
        for (JsonNode s : all()) {
            validator.validate(JSON.writeValueAsString(s)).forEach(v -> problems.add(s.path("id").asString() + ": " + v));
        }
        assertThat(problems).isEmpty();
    }

    @Test
    void germanAndEnglishCoverTheSameScenarios() {
        // A duel between a German and an English player shows both of them the same round.
        Set<String> de = ids("de");
        assertThat(de).isEqualTo(ids("en")).hasSizeGreaterThanOrEqualTo(30);
        Map<String, Boolean> verdictsDe = verdicts("de");
        assertThat(verdictsDe).isEqualTo(verdicts("en"));
    }

    @Test
    void aboutHalfTheMessagesAreGenuine() {
        // Otherwise the game teaches "everything is phishing". Scenes are situational and not counted.
        List<JsonNode> messages = BY_LOCALE.get("de").stream().filter(s -> !s.path("type").asString().equals("scene")).toList();
        long genuine = messages.stream().filter(s -> !s.path("is_attack").asBoolean()).count();
        assertThat((double) genuine / messages.size()).isBetween(0.35, 0.65);
    }

    @Test
    void bodyFlagsQuoteTextThatReallyIsInTheMessage() {
        List<String> problems = new ArrayList<>();
        for (JsonNode s : all()) {
            String body = bodyText(s).toLowerCase();
            for (JsonNode flag : s.path("red_flags")) {
                String target = flag.path("target").asString();
                if (target.startsWith("body:") && !body.contains(target.substring(5).toLowerCase())) {
                    problems.add(s.path("locale").asString() + "/" + s.path("id").asString() + " -> " + target);
                }
            }
        }
        assertThat(problems).isEmpty();
    }

    @Test
    void linkAndAttachmentFlagsPointAtSomethingThatExists() {
        List<String> problems = new ArrayList<>();
        for (JsonNode s : all()) {
            for (JsonNode flag : s.path("red_flags")) {
                String target = flag.path("target").asString();
                if (target.startsWith("link:") && s.path("content").path("links").size() <= Integer.parseInt(target.substring(5))) {
                    problems.add(s.path("id").asString() + " -> " + target);
                }
                if (target.startsWith("attachment:") && s.path("content").path("attachments").size() <= Integer.parseInt(target.substring(11))) {
                    problems.add(s.path("id").asString() + " -> " + target);
                }
            }
        }
        assertThat(problems).isEmpty();
    }

    @Test
    void onlyReservedDomainsAreUsed() {
        // No scenario may point at a real site, so nothing in the game can ever hurt anyone or infringe a brand.
        List<String> problems = new ArrayList<>();
        for (JsonNode s : all()) {
            Matcher m = DOMAIN.matcher(s.path("content").toString());
            while (m.find()) {
                String host = m.group(1).toLowerCase();
                if (!(host.endsWith(".example") || host.endsWith(".test") || host.endsWith(".invalid"))) {
                    problems.add(s.path("id").asString() + " -> " + host);
                }
            }
        }
        assertThat(problems).isEmpty();
    }

    @Test
    void genuineMessagesNeverCountAsDangerous() {
        for (JsonNode s : all()) {
            if (!s.path("is_attack").asBoolean()) {
                assertThat(s.path("dangerous_actions").size()).as(s.path("id").asString()).isZero();
            } else {
                assertThat(s.path("dangerous_actions").size()).as(s.path("id").asString()).isPositive();
            }
        }
    }

    @Test
    void callsAreCompleteTrees() {
        for (JsonNode s : all()) {
            if (!s.path("type").asString().equals("call")) {
                continue;
            }
            JsonNode nodes = s.path("content").path("nodes");
            assertThat(nodes.has(s.path("content").path("start").asString())).isTrue();
            for (JsonNode node : nodes) {
                assertThat(node.path("say").asString()).isNotBlank();
                for (JsonNode option : node.path("options")) {
                    if (option.has("next")) {
                        assertThat(nodes.has(option.path("next").asString())).as(s.path("id").asString()).isTrue();
                    } else {
                        assertThat(option.path("action").asString()).as(s.path("id").asString()).isNotBlank();
                    }
                }
            }
        }
    }

    private static String bodyText(JsonNode s) {
        JsonNode content = s.path("content");
        if (content.has("body_md")) {
            return content.path("body_md").asString();
        }
        StringBuilder sb = new StringBuilder();
        for (JsonNode m : content.path("messages")) {
            sb.append(m.path("text").asString()).append('\n');
        }
        return sb.toString();
    }

    private static Set<String> ids(String locale) {
        Set<String> ids = new TreeSet<>();
        BY_LOCALE.get(locale).forEach(s -> ids.add(s.path("id").asString()));
        return ids;
    }

    private static Map<String, Boolean> verdicts(String locale) {
        Map<String, Boolean> out = new HashMap<>();
        BY_LOCALE.get(locale).forEach(s -> out.put(s.path("id").asString(), s.path("is_attack").asBoolean()));
        return out;
    }
}
