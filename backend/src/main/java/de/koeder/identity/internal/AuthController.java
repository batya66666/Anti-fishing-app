package de.koeder.identity.internal;

import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import de.koeder.identity.CurrentUser;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "auth")
class AuthController {

    private final IdentityService identity;
    private final JwtService jwt;
    private final JwtEncoder encoder;

    AuthController(IdentityService identity, JwtService jwt, JwtEncoder encoder) {
        this.identity = identity;
        this.jwt = jwt;
        this.encoder = encoder;
    }

    record GuestRequest(@NotBlank @Size(min = 16, max = 128) String deviceId, @Size(max = 40) String displayName, String locale) {
    }

    record LoginRequest(@NotBlank @Email String email, @NotBlank @Size(max = 200) String password) {
    }

    record RegisterRequest(@NotBlank @Email String email, @NotBlank @Size(min = 10, max = 200) String password) {
    }

    record TokenResponse(String token, String userId, String role) {
    }

    @PostMapping("/guest")
    TokenResponse guest(@Valid @RequestBody GuestRequest r) {
        return token(identity.guest(r.deviceId(), r.displayName(), r.locale()));
    }

    @PostMapping("/login")
    TokenResponse login(@Valid @RequestBody LoginRequest r) {
        return token(identity.login(r.email(), r.password()));
    }

    @PostMapping("/register")
    TokenResponse register(@Valid @RequestBody RegisterRequest r) {
        return token(identity.register(CurrentUser.id(), r.email(), r.password()));
    }

    private TokenResponse token(Profile p) {
        return new TokenResponse(jwt.issue(encoder, p.id, p.role), p.id.toString(), p.role);
    }
}
