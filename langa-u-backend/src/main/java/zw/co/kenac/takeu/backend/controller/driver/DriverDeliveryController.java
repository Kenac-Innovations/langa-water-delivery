package zw.co.kenac.takeu.backend.controller.driver;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.driver.*;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;

import java.io.IOException;

@Tag(name = "Delivery Services", description = "Driver Delivery Services")
@RequestMapping("${custom.base.path}/driver")
public interface DriverDeliveryController {
    @Operation(summary = "Get all deliveries by status:: Default is All")// todo fix this so
    @GetMapping("/get-all-deliveries")
    ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> findAllDeliveries(
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize,
            @RequestParam(defaultValue = "ALL") String status
    );

    @Operation(summary = "Get all deliveries for a specific driver filtered by status")
    @GetMapping("/{driverId}/deliveries")
    ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> findAllDriverDeliveries(
            @PathVariable Long driverId,
            @RequestParam(defaultValue = "ALL") String status,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize
    );

    @Operation(summary = "Get all open deliveries by vehicle type")
    @GetMapping("/{driverId}/deliveries/open")
// todo
    ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponseWithProposal>>> findAllOpenDeliveriesByVehicleType(
            @PathVariable Long driverId,
            @RequestParam(defaultValue = "OPEN") String status,
            @RequestParam(defaultValue = "") String vehicleType,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize
    );

    @Operation(summary = "Get all driver current deliveries (PICKED_UP AND ASSIGNED)")
    @GetMapping("/{driverId}/current-deliveries")
    ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> findAllDriverAssignedDelivery(
            @PathVariable Long driverId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize
    );

    @Operation(summary = "Get delivery details by ID")
    @GetMapping("/deliveries/{deliveryId}")
    ResponseEntity<GenericResponse<DriverDeliveryResponse>> findDeliveryById(@PathVariable Long deliveryId);

    @Operation(summary = "Propose a driver for a delivery")
    @PostMapping("/deliveries/{deliveryId}/propose")
    ResponseEntity<GenericResponse<String>> proposeDelivery(@PathVariable Long deliveryId, @RequestBody DriverPromptRequest request);

    @Operation(summary = "Mark a delivery as picked up with supporting documentation")
    @PostMapping(value = "/deliveries/{deliveryId}/pickup", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    ResponseEntity<GenericResponse<String>> pickupDelivery(
            @PathVariable Long deliveryId,
            @ModelAttribute @Valid PickupDeliveryRequest request
    ) throws IOException;

    @Operation(summary = "Accept a delivery assignment")
    @PutMapping("/deliveries/{deliveryId}/accept")
    ResponseEntity<GenericResponse<String>> acceptDelivery(@PathVariable Long deliveryId, @RequestBody DriverPromptRequest request);

    @Operation(summary = "Cancel a delivery")
    @PutMapping("/deliveries/{deliveryId}/cancel")
    ResponseEntity<GenericResponse<String>> cancelDelivery(@PathVariable Long deliveryId, @RequestBody DriverPromptRequest request);

    @Operation(summary = "Mark a delivery as completed")
    @PutMapping("/deliveries/{deliveryId}/complete")
    ResponseEntity<GenericResponse<String>> completeDelivery(@PathVariable Long deliveryId, @RequestBody CompleteDeliveryRequest request);

    @Operation(summary = "Delete a driver's proposal for a delivery")
    @DeleteMapping("/deliveries/{deliveryId}/delete-proposal")
    ResponseEntity<GenericResponse<String>> deleteProposal(@PathVariable Long deliveryId, DriverPromptRequest request);

}
