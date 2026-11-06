package de.koeder.shift;

import java.time.LocalDate;
import java.util.UUID;

public record ShiftCompleted(UUID userId, LocalDate date, int score, int correct, int total) {
}
