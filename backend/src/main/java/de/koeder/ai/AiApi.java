package de.koeder.ai;

import java.util.List;

import de.koeder.content.Scenario;

public interface AiApi {

    /**
     * @param text        the suspicious message as text, may be empty when an image is given
     * @param imageBase64 optional screenshot
     * @param mediaType   media type of the screenshot
     */
    CheckResult checkMessage(String text, String imageBase64, String mediaType, String locale);

    GenerationResult generateScenarios(CompanyProfile company, int count, String locale);

    /** @param source "ai" if Claude answered, "rules" if the local rule engine did. The UI shows this honestly. */
    record CheckResult(String verdict, int riskScore, List<Finding> findings, String recommendation, String source) {
    }

    record Finding(String title, String detail) {
    }

    record CompanyProfile(String name, String industry, String tools, String partners, int employees) {
    }

    /** @param source "ai" or "template" */
    record GenerationResult(List<Scenario> scenarios, String source) {
    }
}
