package zw.co.kenac.takeu.backend.controller.waterdelivery;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.GeoPoint;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.ServiceAreaRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.ServiceAreaResponse;

import zw.co.kenac.takeu.backend.service.waterdelivery.ServiceAreaService;

import java.util.List;
import java.util.Map;


/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@RestController
@RequestMapping("/api/v2/service-areas")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
@Tag(name = "Service Areas", description = "Endpoints for managing water delivery service areas")
public class ServiceAreaController {

    private final ServiceAreaService serviceAreaService;

    @PostMapping
    @Operation(summary = "Create a new service area")
    public ResponseEntity<GenericResponse<ServiceAreaResponse>> createServiceArea(
            @Valid @RequestBody ServiceAreaRequest request) {
        log.info("Creating service area: {}", request.getName());
        ServiceAreaResponse response = serviceAreaService.createServiceArea(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(GenericResponse.success(response));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing service area by ID")
    public ResponseEntity<GenericResponse<ServiceAreaResponse>> updateServiceArea(
            @PathVariable Long id,
            @Valid @RequestBody ServiceAreaRequest request) {
        log.info("Updating service area with ID: {}", id);
        ServiceAreaResponse response = serviceAreaService.updateServiceArea(id, request);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a service area by ID")
    public ResponseEntity<GenericResponse<ServiceAreaResponse>> getServiceArea(@PathVariable Long id) {
        return ResponseEntity.ok(GenericResponse.success(serviceAreaService.getServiceArea(id)));
    }

    @GetMapping
    @Operation(summary = "Retrieve all service areas")
    public ResponseEntity<GenericResponse<List<ServiceAreaResponse>>> getAllServiceAreas() {
        List<ServiceAreaResponse> response = serviceAreaService.getAllServiceAreas();
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @GetMapping("/active")
    @Operation(summary = "Get all active service areas")
    public ResponseEntity<GenericResponse<List<ServiceAreaResponse>>> getActiveServiceAreas() {
        List<ServiceAreaResponse> response = serviceAreaService.getActiveServiceAreas();
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @PostMapping("/check-coverage")
    @Operation(summary = "Check if a geographical point is covered by any service area")
    public ResponseEntity<GenericResponse<Map<String, Object>>> checkServiceCoverage(
            @Valid @RequestBody GeoPoint point) {
        log.info("Checking service coverage for point: lat={}, lon={}",
                point.getLatitude(), point.getLongitude());

        List<ServiceAreaResponse> serviceAreas = serviceAreaService.findServiceAreasContainingPoint(point);
        boolean isInServiceArea = serviceAreaService.isPointInAnyActiveServiceArea(point);

        Map<String, Object> result = Map.of(
                "point", point,
                "isInServiceArea", isInServiceArea,
                "serviceAreas", serviceAreas,
                "serviceAreaCount", serviceAreas.size()
        );

        return ResponseEntity.ok(GenericResponse.success(result));
    }

    @PostMapping("/find-by-point")
    @Operation(summary = "Find service areas that contain a specific point")
    public ResponseEntity<GenericResponse<List<ServiceAreaResponse>>> findServiceAreasByPoint(
            @Valid @RequestBody GeoPoint point) {
        log.info("Finding service areas for point: lat={}, lon={}",
                point.getLatitude(), point.getLongitude());

        List<ServiceAreaResponse> response = serviceAreaService.findServiceAreasContainingPoint(point);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @PostMapping("/is-covered")
    @Operation(summary = "Check if a point is in any active service area")
    public ResponseEntity<GenericResponse<Map<String, Boolean>>> isPointCovered(
            @Valid @RequestBody GeoPoint point) {
        boolean isCovered = serviceAreaService.isPointInAnyActiveServiceArea(point);
        return ResponseEntity.ok(GenericResponse.success(Map.of("isCovered", isCovered)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a service area by ID")
    public ResponseEntity<GenericResponse<String>> deleteServiceArea(@PathVariable Long id) {
        log.info("Deleting service area with ID: {}", id);
        serviceAreaService.deleteServiceArea(id);
        return ResponseEntity.ok(GenericResponse.success("Service area deleted successfully"));
    }

    @PatchMapping("/{id}/toggle-status")
    @Operation(summary = "Toggle the active status of a service area")
    public ResponseEntity<GenericResponse<String>> toggleServiceAreaStatus(@PathVariable Long id) {
        log.info("Toggling status for service area with ID: {}", id);
        serviceAreaService.toggleServiceAreaStatus(id);
        return ResponseEntity.ok(GenericResponse.success("Action completed successfully"));
    }

    @GetMapping("/search")
    @Operation(summary = "Search service areas by name")
    public ResponseEntity<GenericResponse<List<ServiceAreaResponse>>> searchServiceAreas(
            @RequestParam String name) {
        log.info("Searching service areas by name: {}", name);
        List<ServiceAreaResponse> response = serviceAreaService.searchServiceAreasByName(name);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
}