package zw.co.kenac.takeu.backend.controller.customer;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.*;

import java.util.List;

@Tag(name = "Client Delivery Management", description = "Client Delivery Management API")
@RequestMapping("${custom.base.path}/client")
public interface ClientDeliveryController {

    @Operation(summary = "Get all client active deliveries for a client {OPEN , ASSIGNED,PICKED UP} ")
    @GetMapping(value = "/{clientId}/deliveries/active")
    ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllActiveDeliveries(
            @PathVariable Long clientId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize
//            @RequestParam(defaultValue = "ALL") String status
    );
    @Operation(summary = "Get all client  deliveries for a client  ")
    @GetMapping(value = "/{clientId}/deliveries")
    ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllDeliveries(
            @PathVariable Long clientId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize,
            @RequestParam(defaultValue = "ALL") String status
    );

    @Operation(summary = "Get a specific delivery by ID for a client")
    @GetMapping("/{clientId}/deliveries/{deliveryId}")
    ResponseEntity<GenericResponse<ClientDeliveryResponse>> findDeliveryById(
            @PathVariable Long clientId,
            @PathVariable Long deliveryId
    );

    @Operation(summary = "Create a new delivery request for a client")
    @PostMapping("/{clientId}/deliveries")
    ResponseEntity<GenericResponse<ClientDeliveryResponse>> createDelivery(
            @PathVariable Long clientId,
            @RequestBody ClientDeliveryRequest deliveryRequest
    );

    @Operation(summary = "Process payment for a client delivery")
    @PostMapping("/{clientId}/deliveries/payment")
    ResponseEntity<GenericResponse<String>> processPayment(
            @PathVariable Long clientId,
            @RequestBody DeliveryPaymentRequest paymentRequest
    );

    @Operation(summary = "Select a delivery driver for a client's delivery")
    @PutMapping("/{clientId}/deliveries/select")
    ResponseEntity<GenericResponse<String>> selectDeliveryDriver(
            @PathVariable Long clientId,
            @RequestBody SelectDriverRequest request
    );

    @Operation(summary = "Cancel a delivery for a client")
    @PutMapping("/{clientId}/deliveries/cancel")
    ResponseEntity<GenericResponse<String>> cancelDelivery(
            @PathVariable Long clientId,
            @RequestBody CancelDeliveryRequest request
    );

    @Operation(summary = "Delete a specific delivery for a client")
    @DeleteMapping("/{clientId}/deliveries/{deliveryId}")
    ResponseEntity<GenericResponse<String>> deleteDelivery(
            @PathVariable Long clientId,
            @PathVariable Long deliveryId
    );

    @Operation(summary = "Get the delivery history for a client")
    @GetMapping("/{clientId}/delivery-history")
    ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllDeliveryHistory(
            @PathVariable Long clientId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize,
            @RequestParam(defaultValue = "ALL") String status
    );

    @Operation(summary = "Find available drivers for a specific delivery")
    @GetMapping("/{deliveryId}/available-drivers")
    ResponseEntity<List<AvailableDriverResponse>> findAvailableDrivers(
            @PathVariable Long deliveryId
    );
}
