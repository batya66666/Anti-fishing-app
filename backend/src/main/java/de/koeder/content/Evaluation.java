package de.koeder.content;

import java.util.List;

/** Server verdict on one answer. */
public record Evaluation(
        Outcome outcome,
        boolean correct,
        boolean attack,
        boolean reported,
        int points,
        int xp,
        int coins,
        int flagsFound,
        int flagsMissed,
        int flagsWrong,
        List<Scenario.RedFlag> redFlags,
        String attackType,
        String explanation) {

    public enum Outcome {
        /** Best possible reaction. */
        CORRECT,
        /** Not fooled, but not the best reaction: an attack deleted instead of reported. */
        SAFE,
        /** Fell for it. Triggers the "HACKED" sequence. */
        HACKED,
        /** A genuine message treated as an attack. */
        FALSE_ALARM,
        /** No harm done, but the wrong reaction. */
        MISSED
    }
}
