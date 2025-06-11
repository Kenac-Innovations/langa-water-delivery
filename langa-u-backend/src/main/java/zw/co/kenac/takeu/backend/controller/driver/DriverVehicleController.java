package zw.co.kenac.takeu.backend.controller.driver;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleResponse;

import java.util.List;

@Tag(name = "Driver Vehicle Management", description = "Driver Vehicle Management API")
@RequestMapping("${custom.base.path}/driver/vehicles")
public interface DriverVehicleController {

    @Operation(
            summary = "Retrieve all vehicles for a driver",
            description = "Returns a list of all vehicles registered to the specified driver"
    )
    @GetMapping("/{driverId}")
    ResponseEntity<GenericResponse<List<DriverVehicleResponse>>> findAllVehicles(@PathVariable Long driverId);

    @Operation(
            summary = "Retrieve a specific vehicle by ID",
            description = "Returns vehicle details for a given driver and vehicle ID"
    )
    @GetMapping("/{driverId}/{vehicleId}")
    ResponseEntity<GenericResponse<DriverVehicleResponse>> findVehicleById(@PathVariable Long driverId, @PathVariable Long vehicleId);

    @Operation(
            summary = "Register a new vehicle for a driver",
            description = "Creates and registers a new vehicle under the specified driver"
    )
    @PostMapping(value = "/{driverId}",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<GenericResponse<DriverVehicleResponse>> createVehicle(@PathVariable Long driverId, @ModelAttribute @Valid DriverVehicleRequest request);

    @Operation(
            summary = "Update an existing vehicle",
            description = "Updates details of an existing vehicle for the specified driver"
    )
    @PutMapping("/{driverId}/{vehicleId}")
    ResponseEntity<GenericResponse<DriverVehicleResponse>> updateVehicle(@PathVariable Long driverId, @PathVariable Long vehicleId, @RequestBody DriverVehicleRequest request);

    @Operation(
            summary = "Delete a vehicle",
            description = "Removes a vehicle from the specified driver’s vehicle list"
    )
    @DeleteMapping("/{driverId}/{vehicleId}")
    ResponseEntity<GenericResponse<String>> deleteVehicle(@PathVariable Long driverId, @PathVariable Long vehicleId);

    @Operation(
            summary = "Switch vehicle",
            description = "Switch vehicle between active and inactive",
            parameters = {
                    @Parameter(name = "driverId", description = "ID of the driver", required = true),
                    @Parameter(name = "vehicleId", description = "ID of the vehicle to activate", required = true)
            }
    )
    @PostMapping("{driverId}/switch/{vehicleId}")
    ResponseEntity<GenericResponse<String>> switchVehicle(@PathVariable Long driverId, @PathVariable Long vehicleId);

}
