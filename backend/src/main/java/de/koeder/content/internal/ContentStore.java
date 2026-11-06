package de.koeder.content.internal;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import de.koeder.content.Scenario;
import de.koeder.content.ScenarioCatalog;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

/**
 * Content is data: JSON files in /content are validated and upserted into Postgres at startup,
 * then served from an in-memory index. Files define every public scenario; companies add their own.
 */
@Service
class ContentStore implements ScenarioCatalog {

    private static final Logger log = LoggerFactory.getLogger(ContentStore.class);

    private final JdbcClient jdbc;
    private final ObjectMapper mapper;
    private final ScenarioValidator validator = new ScenarioValidator();
    private final Map<String, List<Scenario>> publicByLocale = new ConcurrentHashMap<>();
    private final Map<String, Scenario> byKey = new ConcurrentHashMap<>();

    ContentStore(JdbcClient jdbc, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.mapper = mapper;
    }

    /** Runs before any other startup listener: seeders and the game need the catalog. */
    @EventListener(ApplicationReadyEvent.class)
    @Order(0)
    @Transactional
    public void load() throws IOException {
        var resolver = new PathMatchingResourcePatternResolver();
        int count = 0;
        List<String> problems = new ArrayList<>();
        for (Resource file : resolver.getResources("classpath*:content/scenarios/*/*.json")) {
            JsonNode root = mapper.readTree(file.getContentAsString(StandardCharsets.UTF_8));
            for (JsonNode node : root) {
                String json = mapper.writeValueAsString(node);
                validator.validate(json).forEach(v -> problems.add(file.getFilename() + " / " + node.path("id").asString("?") + ": " + v));
                Scenario s = mapper.readValue(json, Scenario.class);
                upsert(s, json, null, "published");
                count++;
            }
        }
        if (!problems.isEmpty()) {
            throw new IllegalStateException("Invalid scenarios:\n" + String.join("\n", problems));
        }
        reloadIndex();
        log.info("Loaded {} scenarios from content files", count);
    }

    private void reloadIndex() {
        publicByLocale.clear();
        byKey.clear();
        jdbc.sql("SELECT doc::text AS doc, org_id, status FROM scenarios").query((rs, n) -> {
            UUID org = rs.getObject("org_id", UUID.class);
            Scenario s = mapper.readValue(rs.getString("doc"), Scenario.class).withOrg(org);
            byKey.put(key(s.id(), s.locale()), s);
            if (org == null) {
                publicByLocale.computeIfAbsent(s.locale(), l -> new ArrayList<>()).add(s);
            }
            return s;
        }).list();
    }

    private void upsert(Scenario s, String json, UUID org, String status) {
        jdbc.sql("""
                INSERT INTO scenarios (id, locale, org_id, type, is_attack, attack_type, difficulty, module, status, doc)
                VALUES (:id, :locale, :org, :type, :attack, :attackType, :difficulty, :module, :status, CAST(:doc AS jsonb))
                ON CONFLICT (id, locale) DO UPDATE SET type = :type, is_attack = :attack, attack_type = :attackType,
                  difficulty = :difficulty, module = :module, status = :status, doc = CAST(:doc AS jsonb)
                """)
                .param("id", s.id()).param("locale", s.locale()).param("org", org, java.sql.Types.OTHER)
                .param("type", s.type()).param("attack", s.attack()).param("attackType", s.attackType())
                .param("difficulty", s.difficulty()).param("module", s.module()).param("status", status).param("doc", json)
                .update();
    }

    @Override
    public Optional<Scenario> find(String id, String locale) {
        Scenario exact = byKey.get(key(id, locale));
        if (exact != null) {
            return Optional.of(exact);
        }
        // A company scenario exists in one language only; a player with another locale still gets it.
        return byKey.values().stream().filter(s -> s.id().equals(id)).findFirst();
    }

    @Override
    public List<Scenario> pool(String locale, UUID orgId) {
        List<Scenario> out = new ArrayList<>(publicByLocale.getOrDefault(locale, List.of()));
        if (orgId != null) {
            out.addAll(orgScenarios(orgId, false));
        }
        return out;
    }

    @Override
    @Transactional
    public Scenario saveOrgScenario(UUID orgId, Scenario scenario, boolean published) {
        // Company ids are namespaced, so nobody can overwrite a public scenario.
        String id = scenario.id().startsWith("org-") ? scenario.id() : "org-" + UUID.randomUUID();
        Scenario stored = new Scenario(id, scenario.type(), scenario.locale(), scenario.difficulty(), scenario.attack(),
                scenario.attackType(), scenario.module(), scenario.consumer(), scenario.content(), scenario.redFlags(),
                scenario.correctActions(), scenario.dangerousActions(), scenario.explanation(), scenario.tags(), null);
        String json = mapper.writeValueAsString(stored);
        List<String> problems = validator.validate(json);
        if (!problems.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_CONTENT, String.join("; ", problems));
        }
        Scenario withOrg = stored.withOrg(orgId);
        upsert(stored, json, orgId, published ? "published" : "draft");
        byKey.put(key(id, stored.locale()), withOrg);
        return withOrg;
    }

    @Override
    public List<Scenario> orgScenarios(UUID orgId, boolean includeDrafts) {
        return jdbc.sql("SELECT doc::text AS doc FROM scenarios WHERE org_id = :org AND (:drafts OR status = 'published') ORDER BY created_at DESC")
                .param("org", orgId).param("drafts", includeDrafts)
                .query((rs, n) -> mapper.readValue(rs.getString("doc"), Scenario.class).withOrg(orgId))
                .list();
    }

    @Override
    @Transactional
    public void publish(UUID orgId, String scenarioId) {
        int changed = jdbc.sql("UPDATE scenarios SET status = 'published' WHERE org_id = :org AND id = :id")
                .param("org", orgId).param("id", scenarioId).update();
        if (changed == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
    }

    @Override
    public Optional<String> forcedDifficulty(UUID orgId) {
        if (orgId == null) {
            return Optional.empty();
        }
        return jdbc.sql("SELECT forced_difficulty FROM content_settings WHERE org_id = :org AND forced_difficulty IS NOT NULL")
                .param("org", orgId).query(String.class).optional();
    }

    @Override
    @Transactional
    public void setForcedDifficulty(UUID orgId, String difficulty) {
        jdbc.sql("""
                INSERT INTO content_settings (org_id, forced_difficulty) VALUES (:org, :d)
                ON CONFLICT (org_id) DO UPDATE SET forced_difficulty = :d
                """).param("org", orgId).param("d", difficulty, java.sql.Types.VARCHAR).update();
    }

    /** Case files are story content, not scored scenarios: served as plain JSON documents. */
    List<Map<String, Object>> cases(String locale) throws IOException {
        var resolver = new PathMatchingResourcePatternResolver();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Resource file : resolver.getResources("classpath*:content/cases/" + locale + "/*.json")) {
            out.add(mapper.readValue(file.getContentAsString(StandardCharsets.UTF_8), new TypeReference<Map<String, Object>>() {
            }));
        }
        out.sort((a, b) -> String.valueOf(a.get("id")).compareTo(String.valueOf(b.get("id"))));
        return out;
    }

    private static String key(String id, String locale) {
        return id + "|" + locale;
    }
}
