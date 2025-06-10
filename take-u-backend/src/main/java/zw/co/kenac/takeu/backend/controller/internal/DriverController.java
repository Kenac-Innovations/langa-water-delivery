package zw.co.kenac.takeu.backend.controller.internal;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.dto.driver.ReviewDriverProfileDto;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;

import java.util.List;

@RequestMapping("${custom.base.path}/drivers")
public interface DriverController {

    @Operation(
            summary = "Fetch all drivers",
            description = "Retrieve a list of all registered drivers"
    )
    @GetMapping
    ResponseEntity<GenericResponse<PaginatedResponse<DriverProfile>>> findAllDrivers(
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize,
            @RequestParam(defaultValue = "ALL") String status
    );

    @Operation(
            summary = "Find driver by ID",
            description = "Retrieve details of a specific driver using their ID"
    )
    @GetMapping("/{driverId}")
    ResponseEntity<GenericResponse<DriverProfile>> findDriverById(@PathVariable Long driverId);


    @Operation(summary = "Filter drivers by status")
    @GetMapping("/filter-by-status")
    ResponseEntity<GenericResponse<PaginatedResponse<DriverProfile>>> filterDriversByStatus(
            @RequestParam(required = true) String status,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "25") int pageSize
    );

    @Operation(
            summary = "Approve driver profile",
            description = "Approve a pending driver profile"
    )
    @PostMapping("/{driverId}/approve")
    ResponseEntity<GenericResponse<String>> approveDriverProfile(@PathVariable Long driverId, @RequestBody DriverApprovalRequest request);

    @Operation(
            summary = "Update driver profile",
            description = "Update profile information of a specific driver"
    )
    @PutMapping("/{driverId}")
    ResponseEntity<GenericResponse<DriverProfile>> updateDriverProfile(@PathVariable Long driverId, @RequestBody Object driverProfile);

    @Operation(
            summary = "Delete driver profile",
            description = "Remove a driver and their profile from the system"
    )
    @DeleteMapping("/{driverId}")
    ResponseEntity<?> deleteDriverProfile(@PathVariable Long driverId);

    @Operation(
            summary = "Review driver profile",
            description = "Admin can review and update the approval status of a driver profile"
    )
    @PostMapping("/review")
    ResponseEntity<GenericResponse<DriverEntity>> reviewDriverProfile(@RequestBody ReviewDriverProfileDto reviewDriverProfileDto);

}
