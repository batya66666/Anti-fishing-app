package de.koeder;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.web.client.RestClient;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/** The Dart client is generated from docs/openapi.json. If the API moves on without it, this fails: run scripts/gen_api.sh. */
class OpenApiContractTest extends IntegrationTestBase {

    @LocalServerPort
    int port;

    @Test
    void committedContractMatchesTheRunningApi() throws IOException {
        var json = JsonMapper.builder().build();
        JsonNode committed = json.readTree(Files.readString(Path.of("..", "docs", "openapi.json")));
        JsonNode live = json.readTree(RestClient.create("http://localhost:" + port).get().uri("/v3/api-docs").retrieve().body(String.class));
        assertThat(live.path("paths")).isEqualTo(committed.path("paths"));
        assertThat(live.path("components")).isEqualTo(committed.path("components"));
    }
}
