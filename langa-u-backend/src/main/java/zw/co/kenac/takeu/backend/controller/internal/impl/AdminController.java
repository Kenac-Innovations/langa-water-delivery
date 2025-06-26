package zw.co.kenac.takeu.backend.controller.internal.impl;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.SelectDriverRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryAdminResponse;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.service.internal.AdminService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
@RestController
@RequestMapping("/api/v2/admin/water-deliveries")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Water Delivery Admin Controller", description = "Endpoints for Admin Management of Water Deliveries")
public class AdminController {

    private final AdminService adminService;

    @Operation(summary = "Get all water deliveries by status", description = "Retrieves a paginated list of water deliveries filtered by delivery status")
    @GetMapping
    public ResponseEntity<GenericResponse<PaginatedResponse<WaterDeliveryAdminResponse>>> getDeliveriesByStatus(
            @RequestParam DeliveryStatus status,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize) {

        PaginatedResponse<WaterDeliveryAdminResponse> response = adminService.getAllDeliveriesByStatus(status, pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Assign delivery to driver", description = "Assigns a water delivery to a specific driver")
    @PostMapping("/{clientId}/assign-driver")
    public ResponseEntity<GenericResponse<WaterDeliveryAdminResponse>> assignDeliveryToDriver(
            @PathVariable Long clientId,
            @RequestBody SelectDriverRequest request) {

        WaterDeliveryAdminResponse response = adminService.assignDeliveryToDriver(clientId, request);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Unassign delivery from driver", description = "Removes driver assignment from a water delivery")
    @PostMapping("/{deliveryId}/unassign-driver")
    public ResponseEntity<GenericResponse<WaterDeliveryAdminResponse>> unassignDeliveryFromDriver(
            @PathVariable Long deliveryId) {

        WaterDeliveryAdminResponse response = adminService.unassignDeliveryFromDriver(deliveryId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
}