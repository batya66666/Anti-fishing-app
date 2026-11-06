package de.koeder.content.internal;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/cases")
@Tag(name = "cases")
class CaseController {

    private final ContentStore store;

    CaseController(ContentStore store) {
        this.store = store;
    }

    @GetMapping
    List<Map<String, Object>> list(@RequestParam(defaultValue = "de") String locale) throws IOException {
        return store.cases("en".equals(locale) ? "en" : "de");
    }

    @GetMapping("/{id}")
    Map<String, Object> one(@PathVariable String id, @RequestParam(defaultValue = "de") String locale) throws IOException {
        return list(locale).stream().filter(c -> id.equals(c.get("id"))).findFirst()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }
}
