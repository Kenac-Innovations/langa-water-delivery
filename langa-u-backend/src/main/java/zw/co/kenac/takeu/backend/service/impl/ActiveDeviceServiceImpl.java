package zw.co.kenac.takeu.backend.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceRequest;
import zw.co.kenac.takeu.backend.dto.device.ActiveDeviceResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ActiveDeviceEntity;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.repository.ActiveDeviceRepository;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.repository.UserRepository;
import zw.co.kenac.takeu.backend.service.ActiveDeviceService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ActiveDeviceServiceImpl implements ActiveDeviceService {

    private final ActiveDeviceRepository activeDeviceRepository;
    private final UserRepository userRepository;
    private final DriverRepository driverRepository;

//    @Override
//    public ActiveDeviceResponse addUserDevice(Long userId, ActiveDeviceRequest request) {
//        UserEntity user = userRepository.findById(userId)
//                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
//
//        // Check if device already exists for this user using push notification token
//        if (request.getPushNotificationToken() != null && !request.getPushNotificationToken().isEmpty()) {
//            activeDeviceRepository.findByTokenAndUserIdAndActiveTrue(request.getPushNotificationToken(), userId)
//                    .ifPresent(existingDevice -> {
//                        existingDevice.setLastActiveTime(LocalDateTime.now());
//                        existingDevice.setDeviceName(request.getDeviceName());
//                        existingDevice.setDevicePlatform(request.getDevicePlatform());
//                        existingDevice.setPushNotificationToken(request.getPushNotificationToken());
//                        activeDeviceRepository.save(existingDevice);
//                    });
//        }
//
//        ActiveDeviceEntity device = new ActiveDeviceEntity();
//        device.setDeviceName(request.getDeviceName());
//        device.setDevicePlatform(request.getDevicePlatform());
//        device.setPushNotificationToken(request.getPushNotificationToken());
//        device.setUser(user);
//        device.setActive(true);
//        device.setLastActiveTime(LocalDateTime.now());
//
//        ActiveDeviceEntity savedDevice = activeDeviceRepository.save(device);
//        return mapToResponse(savedDevice);
//    }
@Override
public ActiveDeviceResponse addUserDevice(Long userId, ActiveDeviceRequest request) {
    UserEntity user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

    // Check if device already exists for this user using push notification token AND platform
    if (request.getPushNotificationToken() != null && !request.getPushNotificationToken().isEmpty()) {
        // Look for existing device with same token AND platform
        List<ActiveDeviceEntity> existingDevices = activeDeviceRepository
                .findAllByTokenAndUserIdAndPlatformAndActiveTrue(
                        request.getPushNotificationToken(),
                        userId,
                        request.getDevicePlatform()
                );

        if (!existingDevices.isEmpty()) {
            // Device with same token and platform already exists - update it instead of creating new one
            ActiveDeviceEntity existingDevice = existingDevices.get(0);

            // If there are duplicates, deactivate the extras
            if (existingDevices.size() > 1) {
                existingDevices.stream()
                        .skip(1) // Skip the first one we're keeping
                        .forEach(device -> {
                            device.setActive(false);
                            activeDeviceRepository.delete(device);
                        });
            }

            // Update the existing device
            existingDevice.setLastActiveTime(LocalDateTime.now());
            existingDevice.setDeviceName(request.getDeviceName());
            // Token and platform remain the same, just update other fields
            ActiveDeviceEntity updatedDevice = activeDeviceRepository.save(existingDevice);
            return mapToResponse(updatedDevice);
        }
    }

    // DEACTIVATE ALL OTHER ACTIVE DEVICES FOR THIS USER
    // This ensures only one device is active per user at any time
    List<ActiveDeviceEntity> allActiveDevices = activeDeviceRepository.findByUserAndActiveTrue(user);
    activeDeviceRepository.deleteAll(allActiveDevices);

    // Create new device - this will be the ONLY active device for this user
    ActiveDeviceEntity device = new ActiveDeviceEntity();
    device.setDeviceName(request.getDeviceName());
    device.setDevicePlatform(request.getDevicePlatform());
    device.setPushNotificationToken(request.getPushNotificationToken());
    device.setUser(user);
    device.setActive(true);
    device.setLastActiveTime(LocalDateTime.now());

    ActiveDeviceEntity savedDevice = activeDeviceRepository.save(device);
    return mapToResponse(savedDevice);
}
@Override
public ActiveDeviceResponse addDriverDevice(Long driverId, ActiveDeviceRequest request) {
    DriverEntity driver = driverRepository.findById(driverId)
            .orElseThrow(() -> new ResourceNotFoundException("Driver not found with id: " + driverId));

    // Check if device already exists for this driver using push notification token AND platformg
    if (request.getPushNotificationToken() != null && !request.getPushNotificationToken().isEmpty()) {
        // Look for existing device with same token AND platform
        List<ActiveDeviceEntity> existingDevices = activeDeviceRepository
                .findAllByTokenAndDriverIdAndPlatformAndActiveTrue(
                        request.getPushNotificationToken(),
                        driverId,
                        request.getDevicePlatform()
                );

        if (!existingDevices.isEmpty()) {
            // Device with same token and platform already exists - update it instead of creating new one
            ActiveDeviceEntity existingDevice = existingDevices.get(0);

            // If there are duplicates, deactivate the extras
            if (existingDevices.size() > 1) {
                existingDevices.stream()
                        .skip(1) // Skip the first one we're keeping
                        .forEach(device -> {
                            device.setActive(false);
                            activeDeviceRepository.save(device);
                        });
            }

            // Update the existing device
            existingDevice.setLastActiveTime(LocalDateTime.now());
            existingDevice.setDeviceName(request.getDeviceName());
            // Token and platform remain the same, just update other fields
            ActiveDeviceEntity updatedDevice = activeDeviceRepository.save(existingDevice);
            return mapToResponse(updatedDevice);
        }
    }
    // DEACTIVATE ALL OTHER ACTIVE DEVICES FOR THIS DRIVER
    // This ensures only one device is active per driver at any time
    List<ActiveDeviceEntity> allActiveDevices = activeDeviceRepository.findByDriverAndActiveTrue(driver);
    activeDeviceRepository.deleteAll(allActiveDevices);
    // Create new device only if no existing device found with same token AND platform
    ActiveDeviceEntity device = new ActiveDeviceEntity();
    device.setDeviceName(request.getDeviceName());
    device.setDevicePlatform(request.getDevicePlatform());
    device.setPushNotificationToken(request.getPushNotificationToken());
    device.setDriver(driver);
    device.setActive(true);
    device.setLastActiveTime(LocalDateTime.now());

    ActiveDeviceEntity savedDevice = activeDeviceRepository.save(device);
    return mapToResponse(savedDevice);
}

    @Override
    public void removeUserDevice(Long userId, Long deviceId) {
        ActiveDeviceEntity device = activeDeviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Active device not found with id: " + deviceId));
        
        if (device.getUser() == null || !device.getUser().getEntityId().equals(userId)) {
            throw new ResourceNotFoundException("Device not found for user with id: " + userId);
        }
        
        device.setActive(false);
        activeDeviceRepository.save(device);
    }

    @Override
    public void removeDriverDevice(Long driverId, Long deviceId) {
        ActiveDeviceEntity device = activeDeviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Active device not found with id: " + deviceId));
        
        if (device.getDriver() == null || !device.getDriver().getEntityId().equals(driverId)) {
            throw new ResourceNotFoundException("Device not found for driver with id: " + driverId);
        }
        
        device.setActive(false);
        activeDeviceRepository.save(device);
    }

    @Override
    public List<ActiveDeviceResponse> getUserDevices(Long userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        
        List<ActiveDeviceEntity> devices = activeDeviceRepository.findByUserAndActiveTrue(user);
        return devices.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<ActiveDeviceResponse> getDriverDevices(Long driverId) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException("Driver not found with id: " + driverId));
        
        List<ActiveDeviceEntity> devices = activeDeviceRepository.findByDriverAndActiveTrue(driver);
        return devices.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public ActiveDeviceResponse updateDeviceActivity(Long deviceId) {
        ActiveDeviceEntity device = activeDeviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Active device not found with id: " + deviceId));
        
        device.setLastActiveTime(LocalDateTime.now());
        ActiveDeviceEntity updatedDevice = activeDeviceRepository.save(device);
        return mapToResponse(updatedDevice);
    }
    
    private ActiveDeviceResponse mapToResponse(ActiveDeviceEntity device) {
        return ActiveDeviceResponse.builder()
                .id(device.getEntityId())
                .deviceName(device.getDeviceName())
                .devicePlatform(device.getDevicePlatform())
                .lastActiveTime(device.getLastActiveTime())
                .pushNotificationToken(device.getPushNotificationToken())
                .active(device.getActive())
                .build();
    }
}
