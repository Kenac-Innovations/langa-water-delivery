package zw.co.kenac.takeu.backend.controller.waterdelivery;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.WaterOrderCreateRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;
import zw.co.kenac.takeu.backend.service.waterdelivery.WaterOrderService;
import zw.co.kenac.takeu.backend.walletmodule.utils.JsonUtil;

import java.util.List;

@RestController
@RequestMapping("/api/v2/water-orders")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Water Orders", description = "Endpoints for managing water delivery orders")
public class WaterOrderController {

    private final WaterOrderService waterOrderService;

    @Operation(summary = "Create a new water order")
    @PostMapping("/create")
    public ResponseEntity<GenericResponse<WaterOrderResponse>> createOrder(@Valid @RequestBody WaterOrderCreateRequestDto request) {
       log.info("WaterOrderController.createOrder: request: {}", JsonUtil.toJson(request));
        WaterOrderResponse response = waterOrderService.createOrder(request);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get all water orders")
    @GetMapping("/getall")
    public ResponseEntity<GenericResponse<PaginatedResponse<WaterOrderResponse>>> getAllOrders(@RequestParam(defaultValue = "ALL") String status,
                                                                                               @RequestParam(defaultValue = "1") int pageNumber,
                                                                                               @RequestParam(defaultValue = "25") int pageSize) {
        PaginatedResponse<WaterOrderResponse> orders = waterOrderService.getAllOrders(status,pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(orders));
    }
    @Operation(summary = "Get client recent Deliveries")
    @GetMapping("/{clientId}")
    public ResponseEntity<GenericResponse<PaginatedResponse<WaterOrderResponse>>> getClientOrder(@PathVariable Long clientId,@RequestParam(defaultValue = "ALL") String status,
                                                                                  @RequestParam(defaultValue = "1") int pageNumber,
                                                                                  @RequestParam(defaultValue = "25") int pageSize) {
        PaginatedResponse<WaterOrderResponse> orders = waterOrderService.getOrdersByClient(clientId,status,pageNumber, pageSize);
        return ResponseEntity.ok(GenericResponse.success(orders));
    }

    @Operation(summary = "Get a specific water order by ID")
    @GetMapping("/{orderId}")
    public ResponseEntity<GenericResponse<WaterOrderResponse>> getOrderById(@PathVariable Long orderId) {
        WaterOrderResponse response = waterOrderService.getOrderById(orderId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

//    @Operation(summary = "Delete a water order by ID")
//    @DeleteMapping("/{orderId}")
//    public ResponseEntity<GenericResponse<String>> deleteOrder(@PathVariable Long orderId) {
//        waterOrderService.deleteOrder(orderId);
//        return ResponseEntity.ok(GenericResponse.success("Order deleted successfully"));
//    }
}