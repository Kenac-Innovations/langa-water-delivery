package zw.co.kenac.takeu.backend.controller.internal;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.internal.SuspendRequest;
import zw.co.kenac.takeu.backend.dto.internal.VehicleResponse;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
@Tag(name = "Vehicle Management Controller")
@RequestMapping("${custom.base.path}/vehicles")
public interface VehicleController {

    @Operation(
            summary = "Get all vehicles",
            description = "Retrieve a paginated list of all vehicles, optionally filtered by vehicle type"
    )
    @GetMapping
    ResponseEntity<PaginatedResponse<VehicleResponse>> findAllVehicles(
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize,
            @RequestParam(defaultValue = "ALL") String vehicleType
    );

    @Operation(
            summary = "Get all vehicles by driver",
            description = "Retrieve a paginated list of vehicles registered to a specific driver"
    )
    @GetMapping("/{driverId}/by-driver")
    ResponseEntity<PaginatedResponse<VehicleResponse>> findAllVehiclesByDriver(
            @PathVariable Long driverId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize
    );

    @Operation(
            summary = "Get vehicle by ID",
            description = "Retrieve a vehicle using its unique ID"
    )
    @GetMapping("/{vehicleId}")
    ResponseEntity<GenericResponse<VehicleResponse>> findAllVehiclesById(@PathVariable Long vehicleId);

    @PutMapping("/{vehicleId}/approve")
    ResponseEntity<GenericResponse<String>> approveVehicle(@PathVariable Long vehicleId, @RequestBody DriverApprovalRequest request);

    @PutMapping("/{vehicleId}/suspend")
    ResponseEntity<GenericResponse<String>> suspendVehicle(@PathVariable Long vehicleId, @RequestBody SuspendRequest request);
}
