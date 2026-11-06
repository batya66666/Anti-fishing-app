package de.koeder.shift.internal;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import de.koeder.content.Evaluation;
import de.koeder.content.PublicScenario;
import de.koeder.identity.CurrentUser;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

@RestController
@RequestMapping("/api")
@Tag(name = "play")
class ShiftController {

    private final ShiftService shifts;

    ShiftController(ShiftService shifts) {
        this.shifts = shifts;
    }

    record ActionRequest(@NotBlank @Size(max = 80) String scenarioId, @NotBlank @Size(max = 60) String action, @PositiveOrZero long ms) {
    }

    record PracticeRequest(@NotBlank @Size(max = 80) String scenarioId,
                           @Pattern(regexp = "review|module|swipe|flags") String context,
                           @Size(max = 60) String action,
                           @Size(max = 40) List<@Size(max = 500) String> flags,
                           @PositiveOrZero long ms) {
    }

    @GetMapping("/shifts/today")
    ShiftService.TodayShift today() {
        return shifts.today(CurrentUser.id());
    }

    @PostMapping("/shifts/{id}/actions")
    ShiftService.ActionResult act(@PathVariable UUID id, @Valid @RequestBody ActionRequest r) {
        return shifts.act(CurrentUser.id(), id, r.scenarioId(), r.action(), r.ms());
    }

    @PostMapping("/practice/actions")
    Evaluation practice(@Valid @RequestBody PracticeRequest r) {
        return shifts.practice(CurrentUser.id(), r.scenarioId(), r.context(), r.action(), r.flags(), r.ms());
    }

    @GetMapping("/review/due")
    List<PublicScenario> reviewDue() {
        return shifts.reviewDue(CurrentUser.id());
    }

    @GetMapping("/swipe/deck")
    List<PublicScenario> swipeDeck() {
        return shifts.swipeDeck(CurrentUser.id());
    }

    @GetMapping("/flags/deck")
    List<PublicScenario> flagsDeck() {
        return shifts.flagsDeck(CurrentUser.id());
    }

    @GetMapping("/modules/{module}")
    List<PublicScenario> module(@PathVariable int module) {
        return shifts.moduleLesson(CurrentUser.id(), module);
    }
}
