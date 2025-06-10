package zw.co.kenac.takeu.backend.controller.internal;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.PriceParamEntity;

import java.util.List;

@RequestMapping("${custom.base.path}/price-settings")
public interface PriceSettingsController {

    @Operation(
            summary = "Get all price settings",
            description = "Retrieve a list of all price configuration settings"
    )
    @GetMapping("/settings")
    ResponseEntity<GenericResponse<List<PriceParamEntity>>> findAllPriceSettings();

    @Operation(
            summary = "Get price setting by ID",
            description = "Retrieve a specific price setting using its ID"
    )
    @GetMapping("/{priceId}")
    ResponseEntity<GenericResponse<PriceParamEntity>> findPriceSettingsById(@PathVariable Long priceId);

    @Operation(
            summary = "Create price setting",
            description = "Add a new price configuration setting"
    )
    @PostMapping("/create")
    ResponseEntity<GenericResponse<PriceParamEntity>> createPriceParam(@RequestBody Object priceParam);

    @Operation(
            summary = "Update price setting",
            description = "Update an existing price configuration setting"
    )
    @PutMapping("/{priceId}")
    ResponseEntity<GenericResponse<PriceParamEntity>> updatePriceParam(@PathVariable Long priceId, @RequestBody Object priceParam);

    @Operation(
            summary = "Delete price setting",
            description = "Delete a price configuration setting by ID"
    )
    @DeleteMapping("/{priceId}")
    ResponseEntity<GenericResponse<String>> deletePriceParam(@PathVariable Long priceId);

}
