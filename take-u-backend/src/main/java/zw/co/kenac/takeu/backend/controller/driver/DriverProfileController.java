package zw.co.kenac.takeu.backend.controller.driver;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.driver.*;

import java.util.Map;

@RequestMapping("${custom.base.path}/driver/profile")
public interface DriverProfileController {

    @Operation(
            summary = "Retrieve driver profile",
            description = "Fetch the profile information for the specified driver"
    )
    @GetMapping("/{driverId}")
    ResponseEntity<GenericResponse<DriverProfile>> findDriverProfile(@PathVariable Long driverId);

    @Operation(
            summary = "Update driver profile",
            description = "Update profile details for the specified driver"
    )
    @PutMapping("/{driverId}")
    ResponseEntity<GenericResponse<DriverProfile>> updateDriverProfile(@PathVariable Long driverId);

    @Operation(
            summary = "Update driver online status",
            description = "Update whether the driver is online or offline"
    )
    @PutMapping("/{driverId}/online-status")
    ResponseEntity<GenericResponse<DriverProfile>> updateOnlineStatus(
            @PathVariable Long driverId,
            @RequestParam("status") Boolean status

    );

    @Operation(
            summary = "Update driver search radius",
            description = "Update the delivery search radius for the driver"
    )
    @PutMapping("/{driverId}/search-radius")
    ResponseEntity<GenericResponse<DriverProfile>> updateSearchRadius(
            @PathVariable Long driverId,
            @RequestParam("radius") Double radius

    );

    @Operation(
            summary = "update driver availability status For example is he online ",
            description = "update driver availability status For example is he online "
    )
    @PutMapping("/{driverId}/update-availability")
    ResponseEntity<GenericResponse<String>> updateAvailabilityStatus(@PathVariable Long driverId, @RequestParam Boolean status);

    @Operation(
            summary = "Delete driver account",
            description = "Delete the driver account associated with the given ID"
    )
    @DeleteMapping("/{driverId}")
    ResponseEntity<GenericResponse<String>> deleteAccount(@PathVariable Long driverId);

    @GetMapping("/download/{bucketType}/{filename}")
    ResponseEntity<InputStreamResource> downloadDocument(
            @PathVariable String bucketType,
            @PathVariable String filename);

    @GetMapping("/url/{bucketType}/{filename}")
    ResponseEntity<Map<String, String>> getDocumentUrl(
            @PathVariable String bucketType,
            @PathVariable String filename,
            @RequestParam(defaultValue = "3600") Integer expirySeconds);

    @DeleteMapping("/{bucketType}/{filename}")
    ResponseEntity<Void> deleteDocument(
            @PathVariable String bucketType,
            @PathVariable String filename);

}
