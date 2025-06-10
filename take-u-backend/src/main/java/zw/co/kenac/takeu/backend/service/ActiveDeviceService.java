package zw.co.kenac.takeu.backend.service;

import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceRequest;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceResponse;

import java.util.List;

public interface ActiveDeviceService {
    
    ActiveDeviceResponse addUserDevice(Long userId, ActiveDeviceRequest request);
    
    ActiveDeviceResponse addDriverDevice(Long driverId, ActiveDeviceRequest request);
    
    void removeUserDevice(Long userId, Long deviceId);
    
    void removeDriverDevice(Long driverId, Long deviceId);
    
    List<ActiveDeviceResponse> getUserDevices(Long userId);
    
    List<ActiveDeviceResponse> getDriverDevices(Long driverId);
    
    ActiveDeviceResponse updateDeviceActivity(Long deviceId);
}
