package de.koeder;

import java.time.Clock;
import java.time.ZoneId;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.modulith.Modulithic;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/** KÖDER: modular monolith. Module boundaries are verified by ModularityTest. */
@Modulithic(systemName = "KOEDER")
@SpringBootApplication
@EnableScheduling
@EnableAsync
@EnableCaching
public class KoederApplication {

    public static void main(String[] args) {
        SpringApplication.run(KoederApplication.class, args);
    }

    /** Shift days and streaks follow the German calendar, regardless of where the server runs. */
    @Bean
    Clock clock() {
        return Clock.system(ZoneId.of("Europe/Berlin"));
    }
}
