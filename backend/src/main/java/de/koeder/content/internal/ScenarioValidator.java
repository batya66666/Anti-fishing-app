package de.koeder.content.internal;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.springframework.core.io.ClassPathResource;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.SpecVersion;
import com.networknt.schema.ValidationMessage;

/** Broken content must fail the build and the startup, not the live demo. */
public final class ScenarioValidator {

    private static final ObjectMapper JSON = new ObjectMapper();
    private final JsonSchema schema;

    public ScenarioValidator() {
        try (InputStream in = new ClassPathResource("content/scenario.schema.json").getInputStream()) {
            schema = JsonSchemaFactory.getInstance(SpecVersion.VersionFlag.V202012).getSchema(in);
        } catch (IOException e) {
            throw new IllegalStateException("scenario.schema.json missing", e);
        }
    }

    /** Returns the violations for one scenario document; empty means valid. */
    public List<String> validate(String json) {
        try {
            JsonNode node = JSON.readTree(json);
            return schema.validate(node).stream().map(ValidationMessage::getMessage).toList();
        } catch (IOException e) {
            return List.of("not valid JSON: " + e.getMessage());
        }
    }
}
