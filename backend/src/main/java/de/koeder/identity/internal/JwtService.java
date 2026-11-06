package de.koeder.identity.internal;

import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.util.List;
import java.util.UUID;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

import com.nimbusds.jose.jwk.source.ImmutableSecret;

@Configuration
class JwtService {

    private final SecretKey key;
    private final Duration ttl;
    private final Clock clock;

    JwtService(@Value("${koeder.jwt.secret}") String secret, @Value("${koeder.jwt.ttl-hours}") long ttlHours, Clock clock) {
        byte[] bytes = secret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("koeder.jwt.secret must be at least 32 bytes");
        }
        this.key = new SecretKeySpec(bytes, "HmacSHA256");
        this.ttl = Duration.ofHours(ttlHours);
        this.clock = clock;
    }

    @Bean
    JwtDecoder jwtDecoder() {
        return NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
    }

    @Bean
    JwtEncoder jwtEncoder() {
        return new NimbusJwtEncoder(new ImmutableSecret<>(key));
    }

    String issue(JwtEncoder encoder, UUID userId, String role) {
        var now = clock.instant();
        var claims = JwtClaimsSet.builder()
                .issuer("koeder")
                .subject(userId.toString())
                .issuedAt(now)
                .expiresAt(now.plus(ttl))
                .claim("roles", List.of(role))
                .build();
        return encoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims)).getTokenValue();
    }
}
