package de.koeder.ai.internal;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import de.koeder.ai.AiApi;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

@RestController
@RequestMapping("/api/ai")
@Tag(name = "ai")
class AiController {

    private final AiApi ai;

    AiController(AiApi ai) {
        this.ai = ai;
    }

    record CheckRequest(@Size(max = 8000) String text,
                        @Size(max = 7_000_000) String imageBase64,
                        @Pattern(regexp = "image/(png|jpeg|webp|gif)") String mediaType,
                        String locale) {
    }

    /** Nothing from this request is stored. Screenshots can hold personal data, so they only pass through. */
    @PostMapping("/check-message")
    AiApi.CheckResult check(@Valid @RequestBody CheckRequest r) {
        boolean noText = r.text() == null || r.text().isBlank();
        boolean noImage = r.imageBase64() == null || r.imageBase64().isBlank();
        if (noText && noImage) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "text or image required");
        }
        return ai.checkMessage(r.text(), r.imageBase64(), r.mediaType(), "en".equals(r.locale()) ? "en" : "de");
    }
}
