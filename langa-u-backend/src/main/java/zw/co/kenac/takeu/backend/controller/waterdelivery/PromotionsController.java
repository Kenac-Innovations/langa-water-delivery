package zw.co.kenac.takeu.backend.controller.waterdelivery;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.waterdelivery.Promotions;
import zw.co.kenac.takeu.backend.service.waterdelivery.PromotionsService;

import java.util.List;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@RestController
@RequestMapping("/api/v2/promotions")
@RequiredArgsConstructor
@Tag(name = "Promotions", description = "Endpoints for managing promotions")
public class PromotionsController {

    private final PromotionsService promotionsService;

    @Operation(summary = "Create a new promotion")
    @PostMapping
    public ResponseEntity<GenericResponse<Promotions>> createPromotion(@Valid @RequestBody Promotions promotion) {
        Promotions response = promotionsService.createPromotion(promotion);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get all promotions")
    @GetMapping
    public ResponseEntity<GenericResponse<List<Promotions>>> getAllPromotions() {
        List<Promotions> promotions = promotionsService.getAllPromotions();
        return ResponseEntity.ok(GenericResponse.success(promotions));
    }

    @Operation(summary = "Get a specific promotion by ID")
    @GetMapping("/{id}")
    public ResponseEntity<GenericResponse<Promotions>> getPromotionById(@PathVariable Long id) {
        Promotions response = promotionsService.getPromotionById(id);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Update an existing promotion")
    @PutMapping("/{id}")
    public ResponseEntity<GenericResponse<Promotions>> updatePromotion(@PathVariable Long id, @Valid @RequestBody Promotions promotion) {
        Promotions response = promotionsService.updatePromotion(id, promotion);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Delete a promotion")
    @DeleteMapping("/{id}")
    public ResponseEntity<GenericResponse<Void>> deletePromotion(@PathVariable Long id) {
        promotionsService.deletePromotion(id);
        return ResponseEntity.ok(GenericResponse.success(null));
    }
}