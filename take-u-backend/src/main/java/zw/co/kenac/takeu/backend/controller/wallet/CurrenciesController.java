package zw.co.kenac.takeu.backend.controller.wallet;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.walletmodule.dto.CurrenciesDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.service.CurrencyService;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */

@RestController
@RequestMapping(value = "/api/v1/currencies")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Currencies Management Controller", description = "Endpoints for Currencies Management Functionality")
public class CurrenciesController {
    private final CurrencyService currencyService;


    @Operation(summary = "Create a new Currency")
    @PostMapping("/create")
    public ResponseEntity<GenericResponse<Currencies>> createCurrency(@RequestBody CurrenciesDto currencyRequest) {
        Currencies currency = currencyService.createCurrency(currencyRequest);
        return ResponseEntity.ok(GenericResponse.success(currency));
    }

    @Operation(summary = "Get Currency by ID")
    @GetMapping("/getCurrencyById/{id}")
    public ResponseEntity<GenericResponse<Currencies>> getCurrencyById(@PathVariable("id") Long id) {
    Currencies currency = currencyService.findCurrencyById(id);
        return ResponseEntity.ok(GenericResponse.success(currency));
    }

    @Operation(summary = "Get Currency by Name")
    @GetMapping("/getCurrencyByName/{name}")
    public ResponseEntity<GenericResponse<Currencies>> getCurrencyByName(@PathVariable("name") String name) {
        Currencies currency = currencyService.getCurrencyByName(name);
        return ResponseEntity.ok(GenericResponse.success(currency));
    }

    @Operation(summary = "Get All Currencies")
    @GetMapping("/getAllCurrency")
    public ResponseEntity<GenericResponse<List<Currencies>>> getAllCurrency() {
        List<Currencies> currencyList = currencyService.getAllCurrencies();
        return ResponseEntity.ok(GenericResponse.success(currencyList));
    }

    @Operation(summary = "Update a Currency")
    @PutMapping("/update")
    public ResponseEntity<GenericResponse<Currencies>> updateCurrency(@RequestBody CurrenciesDto request) {
        Currencies currency = currencyService.editCurrency(request);
        return ResponseEntity.ok(GenericResponse.success(currency));
    }

    @Operation(summary = "Delete Currency")
    @DeleteMapping("/delete")
    public ResponseEntity<GenericResponse<String>> deleteCurrency(@RequestBody CurrenciesDto request) {
        String result = currencyService.deleteCurrency(request);
        return ResponseEntity.ok(GenericResponse.success(result));
    }

    @Operation(summary = "Approve a Currency")
    @PutMapping("/approve")
    public ResponseEntity<GenericResponse<Currencies>> approveCurrency(@RequestBody CurrenciesDto request) {
        Currencies currency = currencyService.approveCurrency(request);
        return ResponseEntity.ok(GenericResponse.success(currency));
    }

    @Operation(summary = "Reject a Currency")
    @PutMapping("/reject")
    public ResponseEntity<GenericResponse<Currencies>> rejectCurrency(@RequestBody CurrenciesDto request) {
        Currencies currency = currencyService.disapproveCurrency(request);
        return ResponseEntity.ok(GenericResponse.success(currency));
    }
}
