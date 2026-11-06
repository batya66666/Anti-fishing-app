package de.koeder.duel.internal;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.random.RandomGenerator;

/**
 * The opponent when no person is available. It plays like someone reading the message:
 * longer texts take longer, hard messages take longer and go wrong more often,
 * and when you have already answered it hurries and makes more mistakes.
 */
final class DuelBot {

    enum Level {
        ROOKIE, ANALYST, VETERAN, CISO;

        /** Null for anything else: the bot then matches the player. */
        static Level parse(String value) {
            if (value == null) {
                return null;
            }
            for (Level l : values()) {
                if (l.name().equalsIgnoreCase(value)) {
                    return l;
                }
            }
            return null;
        }
    }

    /**
     * @param skill probability of being right on the easiest message, before difficulty
     * @param readCps characters read per second
     * @param adaptive matched to the player and keeps a ranked game close
     */
    record Profile(Level level, double skill, double readCps, long reactionMs, int elo, int avatar, boolean adaptive) {

        String name(String locale) {
            boolean en = "en".equals(locale);
            return switch (level) {
                case ROOKIE -> en ? "Otto the intern" : "Praktikant Otto";
                case ANALYST -> en ? "Grete the analyst" : "Analystin Grete";
                case VETERAN -> en ? "Kalle the veteran" : "Veteran Kalle";
                case CISO -> en ? "Frieda the CISO" : "CISO Frieda";
            };
        }

        double accuracy(String difficulty, String kind, int ownScore, int otherScore, boolean rushed) {
            double p = skill - hardness(difficulty) - ("flags".equals(kind) ? 0.05 : 0) - (rushed ? 0.06 : 0);
            if (adaptive) {
                int lead = ownScore - otherScore;
                if (lead < -LEAD_MARGIN) {
                    p += 0.08; // it pulls itself together
                } else if (lead > LEAD_MARGIN) {
                    p -= 0.08; // it gets careless: a good game stays winnable
                }
            }
            return Math.clamp(p, 0.15, 0.98);
        }

        /** How long this bot takes for a message of this length, and always in time for the round. */
        long thinkMs(String difficulty, int chars, String kind, long roundMs, RandomGenerator random) {
            double reading = chars / readCps * 1000 * ("flags".equals(kind) ? 1.3 : 1);
            double doubt = hardness(difficulty) * 6000;
            double noise = 0.75 + random.nextDouble() * 0.55;
            return Math.clamp(Math.round((reactionMs + reading + doubt) * noise), 900L, Math.max(900L, roundMs - 1200));
        }

        long hurryMs(RandomGenerator random) {
            return Math.round(reactionMs * (0.4 + random.nextDouble() * 0.5)) + 300;
        }
    }

    private static final int LEAD_MARGIN = 120;

    private DuelBot() {
    }

    static Profile picked(Level level) {
        return profile(level, false);
    }

    static Profile forRating(int elo) {
        Level level = elo < 950 ? Level.ROOKIE : elo < 1150 ? Level.ANALYST : elo < 1400 ? Level.VETERAN : Level.CISO;
        return profile(level, true);
    }

    private static Profile profile(Level level, boolean adaptive) {
        return switch (level) {
            case ROOKIE -> new Profile(level, 0.74, 70, 2500, 900, 1, adaptive);
            case ANALYST -> new Profile(level, 0.88, 100, 1800, 1150, 3, adaptive);
            case VETERAN -> new Profile(level, 0.98, 140, 1200, 1400, 5, adaptive);
            case CISO -> new Profile(level, 1.08, 200, 800, 1700, 7, adaptive);
        };
    }

    static double hardness(String difficulty) {
        return switch (difficulty) {
            case "bronze" -> 0;
            case "silver" -> 0.06;
            case "gold" -> 0.16;
            default -> 0.28;
        };
    }

    /** Finds each red flag with the given probability and sometimes taps something harmless, as people do. */
    static List<String> tapFlags(List<String> targets, double accuracy, RandomGenerator random) {
        List<String> tapped = new ArrayList<>();
        for (String t : targets) {
            if (random.nextDouble() < accuracy) {
                tapped.add(t);
            }
        }
        if (!targets.contains("subject") && random.nextDouble() < (1 - accuracy) * 0.5) {
            tapped.add("subject");
        }
        return tapped;
    }

    /** What the bot says after a round, if anything. */
    static Optional<String> reaction(boolean botRight, boolean playerRight, boolean botFaster, RandomGenerator random) {
        if (random.nextDouble() > 0.6) {
            return Optional.empty();
        }
        if (botRight && !playerRight) {
            return Optional.of("laugh");
        }
        if (!botRight && playerRight) {
            return Optional.of("shock");
        }
        if (botRight && botFaster) {
            return Optional.of("bolt");
        }
        return botRight ? Optional.of("fire") : Optional.empty();
    }
}
