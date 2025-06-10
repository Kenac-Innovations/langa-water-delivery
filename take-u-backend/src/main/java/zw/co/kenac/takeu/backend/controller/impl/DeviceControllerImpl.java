package zw.co.kenac.takeu.backend.controller.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.DeviceController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceRequest;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceResponse;
import zw.co.kenac.takeu.backend.service.ActiveDeviceService;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class DeviceControllerImpl implements DeviceController {
    
    private final ActiveDeviceService activeDeviceService;
    
    @Override
    public ResponseEntity<GenericResponse<ActiveDeviceResponse>> addUserDevice(Long userId, ActiveDeviceRequest request) {
        ActiveDeviceResponse response = activeDeviceService.addUserDevice(userId, request);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Device registered successfully",
                response
        ));
    }
    
    @Override
    public ResponseEntity<GenericResponse<ActiveDeviceResponse>> addDriverDevice(Long driverId, ActiveDeviceRequest request) {
        ActiveDeviceResponse response = activeDeviceService.addDriverDevice(driverId, request);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Device registered successfully",
                response
        ));
    }
    
    @Override
    public ResponseEntity<GenericResponse<String>> removeUserDevice(Long userId, Long deviceId) {
        activeDeviceService.removeUserDevice(userId, deviceId);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Device removed successfully",
                "Device with ID " + deviceId + " has been removed"
        ));
    }
    
    @Override
    public ResponseEntity<GenericResponse<String>> removeDriverDevice(Long driverId, Long deviceId) {
        activeDeviceService.removeDriverDevice(driverId, deviceId);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Device removed successfully",
                "Device with ID " + deviceId + " has been removed"
        ));
    }
    
    @Override
    public ResponseEntity<GenericResponse<List<ActiveDeviceResponse>>> getUserDevices(Long userId) {
        List<ActiveDeviceResponse> devices = activeDeviceService.getUserDevices(userId);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "User devices retrieved successfully",
                devices
        ));
    }
    
    @Override
    public ResponseEntity<GenericResponse<List<ActiveDeviceResponse>>> getDriverDevices(Long driverId) {
        List<ActiveDeviceResponse> devices = activeDeviceService.getDriverDevices(driverId);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Driver devices retrieved successfully",
                devices
        ));
    }
    
    @Override
    public ResponseEntity<GenericResponse<ActiveDeviceResponse>> pingDevice(Long deviceId) {
        ActiveDeviceResponse updatedDevice = activeDeviceService.updateDeviceActivity(deviceId);
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Device activity updated successfully",
                updatedDevice
        ));
    }
}
