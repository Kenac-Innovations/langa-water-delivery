package zw.co.kenac.takeu.backend.controller.waterdelivery;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;
import zw.co.kenac.takeu.backend.service.waterdelivery.WaterDeliveryService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@RestController
@RequestMapping("/api/v2/water-deliveries")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Water Deliveries", description = "Endpoints for managing water delivery orders")
public class WaterDeliveryController {

    private final WaterDeliveryService waterDeliveryService;

    @Operation(summary = "Get all water deliveries")
    @GetMapping("/getall")
    public ResponseEntity<GenericResponse<PaginatedResponse<WaterDeliveryResponse>>> getAllOrders(@RequestParam(defaultValue = "ALL") String status,
                                                                                                  @RequestParam(defaultValue = "1") int pageNumber,
                                                                                                  @RequestParam(defaultValue = "25") int pageSize) {
        PaginatedResponse<WaterDeliveryResponse> orders = waterDeliveryService.getAllDeliveries(status,pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(orders));
    }
    @Operation(summary = "Get client recent Deliveries")
    @GetMapping("/{clientId}")
    public ResponseEntity<GenericResponse<PaginatedResponse<WaterDeliveryResponse>>> getClientDeliveries(@PathVariable Long clientId, @RequestParam(defaultValue = "ALL") String status,
                                                                                                 @RequestParam(defaultValue = "1") int pageNumber,
                                                                                                 @RequestParam(defaultValue = "25") int pageSize) {
        PaginatedResponse<WaterDeliveryResponse> orders = waterDeliveryService.getDeliveriesByClient(clientId,status,pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(orders));
    }
    @Operation(summary = "Get client recent Driver Deliveries")
    @GetMapping("/{driverId}")
    public ResponseEntity<GenericResponse<PaginatedResponse<WaterDeliveryResponse>>> getDriverDeliveries(@PathVariable Long driverId, @RequestParam(defaultValue = "ALL") String status,
                                                                                                    @RequestParam(defaultValue = "1") int pageNumber,
                                                                                                    @RequestParam(defaultValue = "25") int pageSize) {
        PaginatedResponse<WaterDeliveryResponse> orders = waterDeliveryService.getDeliveriesByDriver(driverId,status,pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(orders));
    }


    @Operation(summary = "Get a specific delivery  by ID")
    @GetMapping("/{orderId}")
    public ResponseEntity<GenericResponse<WaterDeliveryResponse>> getOrderById(@PathVariable Long orderId) {
        WaterDeliveryResponse response = waterDeliveryService.getDeliveryById(orderId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
}
