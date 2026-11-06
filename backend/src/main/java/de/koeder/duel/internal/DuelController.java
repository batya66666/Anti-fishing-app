package de.koeder.duel.internal;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import de.koeder.identity.CurrentUser;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/duels")
@Tag(name = "duels")
class DuelController {

    private final Matchmaking matchmaking;
    private final DuelEngine engine;

    DuelController(Matchmaking matchmaking, DuelEngine engine) {
        this.matchmaking = matchmaking;
        this.engine = engine;
    }

    record CodeResponse(String code) {
    }

    record DuelRef(String duelId) {
    }

    record AnswerMessage(int round, String verdict, List<String> flags) {
    }

    record ReactionMessage(String emoji) {
    }

    @PostMapping("/queue")
    @ResponseStatus(HttpStatus.ACCEPTED)
    void enqueue() {
        matchmaking.join(CurrentUser.id());
    }

    @DeleteMapping("/queue")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void leave() {
        matchmaking.leave(CurrentUser.id());
    }

    @PostMapping("/friendly")
    CodeResponse friendly() {
        return new CodeResponse(matchmaking.createFriendly(CurrentUser.id()));
    }

    @PostMapping("/friendly/bot")
    DuelRef friendlyBot(@RequestParam(required = false) String level) {
        return new DuelRef(matchmaking.friendlyWithBot(CurrentUser.id(), DuelBot.Level.parse(level)).id.toString());
    }

    @PostMapping("/join/{code}")
    DuelRef join(@PathVariable String code) {
        return new DuelRef(matchmaking.joinFriendly(code, CurrentUser.id()).id.toString());
    }

    @GetMapping("/{id}")
    Map<String, Object> state(@PathVariable UUID id) {
        return engine.snapshot(engine.requireParticipant(id, CurrentUser.id()));
    }

    // ---- STOMP: /app/duel/{id}/...

    @MessageMapping("/duel/{id}/ready")
    void ready(@DestinationVariable UUID id, Principal user) {
        engine.ready(id, UUID.fromString(user.getName()));
    }

    @MessageMapping("/duel/{id}/answer")
    void answer(@DestinationVariable UUID id, AnswerMessage m, Principal user) {
        engine.answer(id, UUID.fromString(user.getName()), m.round(), m.verdict(), m.flags());
    }

    @MessageMapping("/duel/{id}/react")
    void react(@DestinationVariable UUID id, ReactionMessage m, Principal user) {
        engine.react(id, UUID.fromString(user.getName()), m.emoji());
    }
}
