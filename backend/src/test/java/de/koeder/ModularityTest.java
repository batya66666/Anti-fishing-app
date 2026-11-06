package de.koeder;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;
import org.springframework.modulith.docs.Documenter;

/** Fails the build when a module reaches into another module's internals or a dependency cycle appears. */
class ModularityTest {

    private final ApplicationModules modules = ApplicationModules.of(KoederApplication.class);

    @Test
    void moduleBoundariesHold() {
        modules.verify();
    }

    @Test
    void writesArchitectureDocs() {
        new Documenter(modules).writeModulesAsPlantUml().writeIndividualModulesAsPlantUml();
    }
}
