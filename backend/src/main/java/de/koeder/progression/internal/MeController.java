package de.koeder.progression.internal;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import de.koeder.duel.DuelApi;
import de.koeder.identity.CurrentUser;
import de.koeder.identity.IdentityApi;
import de.koeder.identity.UserRef;
import de.koeder.shift.ShiftApi;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;

@RestController
@RequestMapping("/api")
@Tag(name = "profile")
class MeController {

    private final ProgressionService progression;
    private final IdentityApi identity;
    private final ShiftApi shifts;
    private final DuelApi duels;

    MeController(ProgressionService progression, IdentityApi identity, ShiftApi shifts, DuelApi duels) {
        this.progression = progression;
        this.identity = identity;
        this.shifts = shifts;
        this.duels = duels;
    }

    record MeResponse(String id, String displayName, int avatar, String locale, String mode, String role, String orgId,
                      boolean publicBoard, String email,
                      int xp, int level, String title, int levelFloor, int levelCeil, int coins,
                      int streak, int bestStreak, int streakFreezes,
                      int shiftsDone, int attacksReported, int attacksSeen, int timesHacked, int falseAlarms, int answers, int answersCorrect,
                      int elo, int wins, int losses,
                      String leagueTier, int weeklyXp,
                      long reviewsDue, ShiftApi.Energy energy, Map<Integer, Integer> moduleProgress, Map<Integer, Integer> moduleTotals,
                      String forcedDifficulty, List<String> badges) {
    }

    record SettingsRequest(@Size(min = 1, max = 40) String displayName, Integer avatar, String locale, String mode, Boolean publicBoard) {
    }

    @GetMapping("/me")
    MeResponse me() {
        return load(CurrentUser.id());
    }

    @PatchMapping("/me")
    MeResponse update(@Valid @RequestBody SettingsRequest r) {
        UUID id = CurrentUser.id();
        identity.updateSettings(id, new IdentityApi.SettingsChange(r.displayName(), r.avatar(), r.locale(), r.mode(), r.publicBoard()));
        return load(id);
    }

    /** DSGVO Art. 20: everything we hold about this user, in one JSON document. */
    @GetMapping("/me/export")
    Map<String, Object> export() {
        UUID id = CurrentUser.id();
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("profile", identity.require(id));
        out.put("progress", progression.progressRow(id));
        out.put("badges", progression.badges(id));
        out.put("attempts", shifts.exportAttempts(id));
        return out;
    }

    /** DSGVO Art. 17: one click, everything gone. Foreign keys cascade from profiles. */
    @DeleteMapping("/me")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void delete() {
        identity.deleteAccount(CurrentUser.id());
    }

    @PostMapping("/me/demo-reset")
    MeResponse demoReset() {
        UUID id = CurrentUser.id();
        shifts.demoReset(id);
        return load(id);
    }

    @GetMapping("/leaderboard")
    List<ProgressionService.BoardRow> leaderboard(@RequestParam(defaultValue = "global") String scope) {
        UUID org = "org".equals(scope) ? identity.orgOf(CurrentUser.id()).orElse(null) : null;
        if ("org".equals(scope) && org == null) {
            return List.of();
        }
        return progression.leaderboard(scope, org);
    }

    private MeResponse load(UUID id) {
        UserRef u = identity.require(id);
        Map<String, Object> p = progression.progressRow(id);
        Map<String, Object> league = progression.league(id);
        DuelApi.Rating rating = duels.rating(id);
        int xp = num(p, "xp");
        int level = Levels.levelFor(xp);
        return new MeResponse(u.id().toString(), u.displayName(), u.avatar(), u.locale(), u.mode(), u.role(),
                u.orgId() == null ? null : u.orgId().toString(), u.publicBoard(), u.email(),
                xp, level, Levels.title(level), Levels.currentThreshold(level), Levels.nextThreshold(level), num(p, "coins"),
                num(p, "streak"), num(p, "best_streak"), num(p, "streak_freezes"),
                num(p, "shifts_done"), num(p, "attacks_reported"), num(p, "attacks_seen"), num(p, "times_hacked"),
                num(p, "false_alarms"), num(p, "answers"), num(p, "answers_correct"),
                rating.elo(), rating.wins(), rating.losses(),
                String.valueOf(league.get("tier")), num(league, "weekly_xp"),
                shifts.reviewsDue(id), shifts.energy(id), shifts.moduleProgress(id), shifts.moduleTotals(id),
                shifts.forcedDifficulty(id).orElse(null), progression.badges(id));
    }

    private static int num(Map<String, Object> m, String k) {
        return ((Number) m.get(k)).intValue();
    }
}
