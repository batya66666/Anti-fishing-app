package de.koeder.identity.internal;

import java.io.IOException;
import java.time.Duration;
import java.util.concurrent.TimeUnit;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;

import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/** Per-IP limits on the endpoints that cost money (AI) or invite guessing (login). */
@Component
class RateLimitFilter extends OncePerRequestFilter {

    private final Cache<String, Bucket> buckets = Caffeine.newBuilder().maximumSize(50_000).expireAfterAccess(1, TimeUnit.HOURS).build();

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return !(path.startsWith("/api/auth/") || path.startsWith("/api/ai/") || path.endsWith("/scenarios/generate"));
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        boolean expensive = !request.getRequestURI().startsWith("/api/auth/");
        String key = (expensive ? "ai:" : "auth:") + request.getRemoteAddr();
        Bucket bucket = buckets.get(key, k -> newBucket(expensive));
        if (bucket.tryConsume(1)) {
            chain.doFilter(request, response);
        } else {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setHeader("Retry-After", "60");
        }
    }

    private static Bucket newBucket(boolean expensive) {
        // Generous for auth: a whole jury on one venue Wi-Fi shares an IP during the demo.
        return Bucket.builder()
                .addLimit(l -> l.capacity(expensive ? 20 : 120).refillGreedy(expensive ? 20 : 120, Duration.ofMinutes(1)))
                .build();
    }
}
