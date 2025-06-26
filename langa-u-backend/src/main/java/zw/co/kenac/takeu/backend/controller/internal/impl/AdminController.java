package zw.co.kenac.takeu.backend.controller.internal.impl;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.ClientDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.service.internal.AdminService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
@RestController
@RequestMapping("/api/v1/admin/deliveries")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Admin Deliveries Controller", description = "Endpoints for Admin Management of Client Deliveries")
public class AdminController {

    private final AdminService adminService;

    @Operation(summary = "Get all deliveries by status", description = "Retrieves a paginated list of client deliveries filtered by delivery status")
    @GetMapping
    public ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> getDeliveriesByStatus(
            @RequestParam DeliveryStatus status,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize) {

        PaginatedResponse<DriverDeliveryResponse> response = adminService.getAllDeliveriesByStatus(status, pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
}