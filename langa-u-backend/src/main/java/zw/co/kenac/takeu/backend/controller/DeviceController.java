package zw.co.kenac.takeu.backend.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceRequest;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceResponse;

import java.util.List;


@Tag(name = "Device Management", description = "API for managing active devices")
@RequestMapping("${custom.base.path}")
public interface DeviceController {
    
    @Operation(summary = "Register a device for a user")
    @PostMapping("/users/{userId}/devices")
    ResponseEntity<GenericResponse<ActiveDeviceResponse>> addUserDevice(
            @PathVariable Long userId,
            @RequestBody ActiveDeviceRequest request);
    
    @Operation(summary = "Register a device for a driver")
    @PostMapping("/drivers/{driverId}/devices")
    ResponseEntity<GenericResponse<ActiveDeviceResponse>> addDriverDevice(
            @PathVariable Long driverId,
            @RequestBody ActiveDeviceRequest request);
    
    @Operation(summary = "Remove a user device")
    @DeleteMapping("/users/{userId}/devices/{deviceId}")
    ResponseEntity<GenericResponse<String>> removeUserDevice(
            @PathVariable Long userId,
            @PathVariable Long deviceId);
    
    @Operation(summary = "Remove a driver device")
    @DeleteMapping("/drivers/{driverId}/devices/{deviceId}")
    ResponseEntity<GenericResponse<String>> removeDriverDevice(
            @PathVariable Long driverId,
            @PathVariable Long deviceId);
    
    @Operation(summary = "Get all active devices for a user")
    @GetMapping("/users/{userId}/devices")
    ResponseEntity<GenericResponse<List<ActiveDeviceResponse>>> getUserDevices(
            @PathVariable Long userId);
    
    @Operation(summary = "Get all active devices for a driver")
    @GetMapping("/drivers/{driverId}/devices")
    ResponseEntity<GenericResponse<List<ActiveDeviceResponse>>> getDriverDevices(
            @PathVariable Long driverId);
    
    @Operation(summary = "Update device last activity time")
    @PutMapping("/devices/{deviceId}/ping")
    ResponseEntity<GenericResponse<ActiveDeviceResponse>> pingDevice(
            @PathVariable Long deviceId);
}
