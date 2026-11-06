package de.koeder.identity.internal;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.tags.Tag;

/** Where others can reach this server. A laptop on localhost still has to print a QR code that works on a phone. */
@RestController
@RequestMapping("/api/public")
@Tag(name = "public")
class PublicInfoController {

    private final String publicUrl;

    PublicInfoController(@Value("${koeder.public-url}") String publicUrl) {
        this.publicUrl = publicUrl;
    }

    record PublicInfo(String publicUrl) {
    }

    @GetMapping("/info")
    PublicInfo info() {
        return new PublicInfo(publicUrl.isBlank() ? null : publicUrl);
    }
}
