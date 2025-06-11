package zw.co.kenac.takeu.backend.controller.internal.impl;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.internal.CommissionDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.CommissionEntity;
import zw.co.kenac.takeu.backend.service.internal.CommissionService;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@RestController
@RequestMapping("/api/v1/commissions")
@RequiredArgsConstructor
@Tag(name = "Commission Management", description = "APIs for managing commission settings")
public class CommissionController {

    private final CommissionService commissionService;

    @PostMapping
    @Operation(summary = "Create a new commission", description = "Creates a new commission with the provided details")
    public ResponseEntity<GenericResponse<CommissionDto>> createCommission(@Valid @RequestBody CommissionDto commissionDto) {
        CommissionEntity commission = commissionService.createCommission(commissionDto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new GenericResponse<>(
                        true,
                        "Commission created successfully",
                        mapToDto(commission)
                ));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a commission", description = "Updates an existing commission with the provided details")
    public ResponseEntity<GenericResponse<CommissionDto>> updateCommission(
            @PathVariable Long id,
            @Valid @RequestBody CommissionDto commissionDto) {
        
        CommissionEntity commission = commissionService.updateCommission(id, commissionDto);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Commission updated successfully",
                mapToDto(commission)
        ));
    }

    @PutMapping("/{id}/activate")
    @Operation(summary = "Activate a commission", description = "Activates the specified commission and deactivates all others")
    public ResponseEntity<GenericResponse<CommissionDto>> activateCommission(@PathVariable Long id) {
        CommissionEntity commission = commissionService.activateCommission(id);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Commission activated successfully",
                mapToDto(commission)
        ));
    }

    @PutMapping("/{id}/deactivate")
    @Operation(summary = "Deactivate a commission", description = "Deactivates the specified commission")
    public ResponseEntity<GenericResponse<CommissionDto>> deactivateCommission(@PathVariable Long id) {
        CommissionEntity commission = commissionService.deactivateCommission(id);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Commission deactivated successfully",
                mapToDto(commission)
        ));
    }

    @GetMapping
    @Operation(summary = "Get all commissions", description = "Returns a list of all commissions")
    public ResponseEntity<GenericResponse<List<CommissionDto>>> getAllCommissions() {
        List<CommissionEntity> commissions = commissionService.getAllCommissions();
        List<CommissionDto> commissionDtos = commissions.stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Commissions retrieved successfully",
                commissionDtos
        ));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a commission by ID", description = "Returns the commission with the specified ID")
    public ResponseEntity<GenericResponse<CommissionDto>> getCommissionById(@PathVariable Long id) {
        CommissionEntity commission = commissionService.getCommissionById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Commission not found with id: " + id));
        
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Commission retrieved successfully",
                mapToDto(commission)
        ));
    }

    @GetMapping("/active")
    @Operation(summary = "Get active commission", description = "Returns the currently active commission")
    public ResponseEntity<GenericResponse<CommissionDto>> getActiveCommission() {
        CommissionEntity commission = commissionService.getActiveCommission()
                .orElseThrow(() -> new ResourceNotFoundException("No active commission found"));
        
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Active commission retrieved successfully",
                mapToDto(commission)
        ));
    }

    @GetMapping("/calculate")
    @Operation(summary = "Calculate commission", description = "Calculates commission for the given amount using the active commission")
    public ResponseEntity<GenericResponse<BigDecimal>> calculateCommission(@RequestParam BigDecimal amount) {
        BigDecimal commission = commissionService.calculateCommissionForAmount(amount);
        
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Commission calculated successfully",
                commission
        ));
    }

    private CommissionDto mapToDto(CommissionEntity commission) {
        return CommissionDto.builder()
                .id(commission.getEntityId())
                .name(commission.getName())
                .description(commission.getDescription())
                .percentageValue(commission.getPercentageAsDisplayValue())
                .status(commission.getStatus())
                .isActive(commission.isActive())
                .createTime(commission.getCreateTime())
                .updateTime(commission.getUpdateTime())
                .build();
    }
} 