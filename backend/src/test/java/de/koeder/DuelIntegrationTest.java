package de.koeder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.awaitility.Awaitility.await;

import java.lang.reflect.Type;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.TimeUnit;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.MediaType;
import org.springframework.messaging.converter.JacksonJsonMessageConverter;
import org.springframework.messaging.simp.stomp.StompFrameHandler;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.web.client.RestClient;
import org.springframework.web.socket.WebSocketHttpHeaders;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

/** Two real STOMP clients play a full match over a real WebSocket, plus the bot fallback. */
class DuelIntegrationTest extends IntegrationTestBase {

    @LocalServerPort
    int port;

    private record Player(String token, String userId, StompSession session, List<Map<String, Object>> events) {
    }

    @SuppressWarnings("unchecked")
    private Player connect() throws Exception {
        Map<String, Object> auth = RestClient.create("http://localhost:" + port).post().uri("/api/auth/guest").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("deviceId", UUID.randomUUID().toString(), "locale", "de")).retrieve().body(Map.class);
        String token = (String) auth.get("token");
        WebSocketStompClient stomp = new WebSocketStompClient(new StandardWebSocketClient());
        stomp.setMessageConverter(new JacksonJsonMessageConverter());
        StompHeaders connect = new StompHeaders();
        connect.add("Authorization", "Bearer " + token);
        StompSession session = stomp.connectAsync("ws://localhost:" + port + "/ws", new WebSocketHttpHeaders(), connect, new StompSessionHandlerAdapter() {
        }).get(5, TimeUnit.SECONDS);
        return new Player(token, (String) auth.get("userId"), session, new CopyOnWriteArrayList<>());
    }

    private static void listen(Player p, String destination) {
        p.session.subscribe(destination, new StompFrameHandler() {
            @Override
            public Type getPayloadType(StompHeaders headers) {
                return Map.class;
            }

            @Override
            @SuppressWarnings("unchecked")
            public void handleFrame(StompHeaders headers, Object payload) {
                p.events.add((Map<String, Object>) payload);
            }
        });
    }

    private RestClient api(Player p) {
        return RestClient.builder().baseUrl("http://localhost:" + port).defaultHeader("Authorization", "Bearer " + p.token).build();
    }

    private static List<Map<String, Object>> ofType(Player p, String type) {
        return p.events.stream().filter(e -> type.equals(e.get("type"))).toList();
    }

    @Test
    void connectingWithoutAValidTokenIsRefused() {
        WebSocketStompClient stomp = new WebSocketStompClient(new StandardWebSocketClient());
        StompHeaders connect = new StompHeaders();
        connect.add("Authorization", "Bearer not-a-token");
        assertThatThrownBy(() -> stomp.connectAsync("ws://localhost:" + port + "/ws", new WebSocketHttpHeaders(), connect, new StompSessionHandlerAdapter() {
        }).get(5, TimeUnit.SECONDS)).isNotNull();
    }

    @Test
    @SuppressWarnings("unchecked")
    void twoPlayersFinishAFriendlyMatchByCode() throws Exception {
        Player host = connect();
        Player guest = connect();
        String code = (String) api(host).post().uri("/api/duels/friendly").retrieve().body(Map.class).get("code");
        assertThat(code).hasSize(6);

        listen(host, "/user/queue/match-found");
        Thread.sleep(200); // subscription must be active before the join announces the match
        String duelId = (String) api(guest).post().uri("/api/duels/join/" + code).retrieve().body(Map.class).get("duelId");
        await().atMost(Duration.ofSeconds(3)).until(() -> host.events.stream().anyMatch(e -> duelId.equals(e.get("duelId"))));

        String topic = "/topic/duel/" + duelId;
        listen(host, topic);
        listen(guest, topic);
        Thread.sleep(200);
        host.session.send("/app/duel/" + duelId + "/ready", Map.of());
        guest.session.send("/app/duel/" + duelId + "/ready", Map.of());

        // Host answers "attack" immediately, guest lets some rounds time out: everything is decided server-side.
        List<Integer> answered = new ArrayList<>();
        await().atMost(Duration.ofSeconds(40)).pollInterval(Duration.ofMillis(30)).until(() -> {
            for (Map<String, Object> round : ofType(host, "round")) {
                int no = (Integer) round.get("no");
                if (!answered.contains(no)) {
                    answered.add(no);
                    // The solution is not on the wire until the round is over.
                    assertThat(round.toString()).doesNotContain("is_attack", "isAttack", "correctActions", "redFlags", "explanation");
                    String kind = (String) round.get("kind");
                    Map<String, Object> answer = kind.equals("flags")
                            ? Map.of("round", no, "flags", List.of("from_email"))
                            : Map.of("round", no, "verdict", "attack");
                    host.session.send("/app/duel/" + duelId + "/answer", answer);
                    if (no == 1) {
                        // The second answer of the same player in a round must not count.
                        host.session.send("/app/duel/" + duelId + "/answer", Map.of("round", 1, "verdict", "legit"));
                    }
                    guest.session.send("/app/duel/" + duelId + "/answer", Map.of("round", no, "verdict", "legit"));
                }
            }
            return !ofType(host, "finished").isEmpty();
        });

        assertThat(answered).containsExactly(1, 2, 3, 4, 5);
        assertThat(ofType(guest, "round_result")).hasSize(5);
        Map<String, Object> finished = ofType(host, "finished").get(0);
        Map<String, Object> a = (Map<String, Object>) finished.get("a");
        int sum = ((List<Integer>) a.get("perRound")).stream().mapToInt(Integer::intValue).sum();
        assertThat(a.get("score")).isEqualTo(sum);
        // Friendly matches never touch the rating.
        assertThat(a.get("eloDelta")).isEqualTo(0);
        assertThat(api(host).get().uri("/api/me").retrieve().body(Map.class).get("elo")).isEqualTo(1000);
        assertThat((List<String>) api(host).get().uri("/api/me").retrieve().body(Map.class).get("badges")).contains("first_duel");
    }

    @Test
    @SuppressWarnings("unchecked")
    void aBotStepsInWhenNobodyElseQueues() throws Exception {
        Player solo = connect();
        listen(solo, "/user/queue/match-found");
        Thread.sleep(200);
        assertThat(api(solo).post().uri("/api/duels/queue").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(202);
        await().atMost(Duration.ofSeconds(8)).until(() -> solo.events.stream().anyMatch(e -> e.containsKey("duelId")));
        String duelId = (String) solo.events.stream().filter(e -> e.containsKey("duelId")).findFirst().orElseThrow().get("duelId");

        listen(solo, "/topic/duel/" + duelId);
        Thread.sleep(200);
        solo.session.send("/app/duel/" + duelId + "/ready", Map.of());

        await().atMost(Duration.ofSeconds(40)).until(() -> !ofType(solo, "finished").isEmpty());
        Map<String, Object> state = ofType(solo, "state").get(0);
        assertThat(((Map<String, Object>) state.get("b")).get("bot")).isEqualTo(true);
        Map<String, Object> finished = ofType(solo, "finished").get(0);
        // Even from the ranked queue, a game against a bot never moves the rating.
        assertThat(((Map<String, Object>) finished.get("a")).get("eloDelta")).isEqualTo(0);
        Map<String, Object> me = api(solo).get().uri("/api/me").retrieve().body(Map.class);
        assertThat(me.get("elo")).isEqualTo(1000);
    }

    @Test
    void aWrongCodeIsRefused() throws Exception {
        Player p = connect();
        var client = RestClient.builder().baseUrl("http://localhost:" + port).defaultHeader("Authorization", "Bearer " + p.token)
                .defaultStatusHandler(s -> s.isError(), (req, res) -> {
                }).build();
        assertThat(client.post().uri("/api/duels/join/NOPE00").retrieve().toBodilessEntity().getStatusCode().value()).isEqualTo(404);
    }
}
