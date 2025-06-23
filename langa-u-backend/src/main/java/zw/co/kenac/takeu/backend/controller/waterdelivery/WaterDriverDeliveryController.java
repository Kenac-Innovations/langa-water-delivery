package zw.co.kenac.takeu.backend.controller.waterdelivery;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.DriverWaterDeliveryCompleteRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.service.driver.DriverWaterDeliveryService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 13/6/2025
 */
@RestController
@RequestMapping("/api/v2/driver/water-delivery")
@RequiredArgsConstructor
@Tag(name = "Driver Water Delivery", description = "Endpoints for driver water delivery management")
public class WaterDriverDeliveryController {

    private final DriverWaterDeliveryService driverWaterDeliveryService;

    @Operation(summary = "Accept a water delivery assignment")
    @PostMapping("/{waterDeliveryId}/accept/{driverId}")
    public ResponseEntity<GenericResponse<WaterDeliveryResponse>> acceptDelivery(
            @PathVariable Long driverId,
            @PathVariable Long waterDeliveryId) {
        WaterDeliveryResponse response = driverWaterDeliveryService.acceptDelivery(driverId, waterDeliveryId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Start a water delivery")
    @PostMapping("/{waterDeliveryId}/start")
    public ResponseEntity<GenericResponse<WaterDeliveryResponse>> startDelivery(
            @PathVariable Long waterDeliveryId) {
        WaterDeliveryResponse response = driverWaterDeliveryService.startDelivery(waterDeliveryId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Complete a water delivery")
    @PostMapping("/complete")
    public ResponseEntity<GenericResponse<WaterDeliveryResponse>> completeDelivery(
            @RequestBody DriverWaterDeliveryCompleteRequest request) {
        WaterDeliveryResponse response = driverWaterDeliveryService.completeDelivery(request);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Cancel a water delivery assignment")
    @PostMapping("/{waterDeliveryId}/cancel/{driverId}")
    public ResponseEntity<GenericResponse<WaterDeliveryResponse>> cancelDelivery(
            @PathVariable Long driverId,
            @PathVariable Long waterDeliveryId) {
        WaterDeliveryResponse response = driverWaterDeliveryService.cancelDelivery(driverId, waterDeliveryId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
}