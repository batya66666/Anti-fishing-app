package de.koeder.identity.internal;

import java.security.Principal;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessagingException;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import de.koeder.identity.IdentityApi;

/** STOMP over plain WebSocket. Every CONNECT must present a valid JWT. */
@Configuration
@EnableWebSocketMessageBroker
class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final JwtDecoder decoder;
    private final Converter<Jwt, AbstractAuthenticationToken> converter;
    private final IdentityApi identity;
    private final String[] origins;

    WebSocketConfig(JwtDecoder decoder,
                    org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter converter,
                    IdentityApi identity,
                    @Value("${koeder.cors.allowed-origins}") String origins) {
        this.decoder = decoder;
        this.converter = converter;
        this.identity = identity;
        this.origins = origins.split(",");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").setAllowedOriginPatterns(origins);
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes("/app");
        registry.setUserDestinationPrefix("/user");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, MessageChannel channel) {
                StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
                if (accessor == null) {
                    return message;
                }
                if (StompCommand.CONNECT.equals(accessor.getCommand())) {
                    accessor.setUser(authenticate(accessor.getFirstNativeHeader("Authorization")));
                } else if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
                    authorizeSubscribe(accessor);
                }
                return message;
            }
        });
    }

    private Principal authenticate(String header) {
        if (header == null || !header.startsWith("Bearer ")) {
            throw new MessagingException("Missing bearer token");
        }
        try {
            return converter.convert(decoder.decode(header.substring(7)));
        } catch (JwtException e) {
            throw new MessagingException("Invalid token");
        }
    }

    /** A company's live feed is only visible to managers of exactly that company. */
    private void authorizeSubscribe(StompHeaderAccessor accessor) {
        String destination = accessor.getDestination();
        if (destination == null || !destination.startsWith("/topic/org/")) {
            return;
        }
        Principal user = accessor.getUser();
        if (user == null) {
            throw new MessagingException("Not connected");
        }
        var ref = identity.require(UUID.fromString(user.getName()));
        String[] parts = destination.split("/");
        boolean allowed = parts.length >= 4 && ref.orgId() != null && ref.orgId().toString().equals(parts[3])
                && ("MANAGER".equals(ref.role()) || "ADMIN".equals(ref.role()));
        if (!allowed) {
            throw new MessagingException("Forbidden");
        }
    }
}
