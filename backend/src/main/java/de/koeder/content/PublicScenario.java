package de.koeder.content;

import java.util.Map;

/** What the client sees before answering: the message, not the verdict. */
public record PublicScenario(String id, String type, String locale, String difficulty, int module, Map<String, Object> content) {
}
