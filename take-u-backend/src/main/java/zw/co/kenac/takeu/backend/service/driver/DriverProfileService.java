package zw.co.kenac.takeu.backend.service.driver;

import zw.co.kenac.takeu.backend.dto.driver.ReviewDriverProfileDto;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;

public interface DriverProfileService {

    DriverProfile findDriverProfile(Long driverId);

    DriverProfile updateDriverProfile(Long driverId);
    DriverProfile updateOnlineStatus(Long driverId, Boolean online);
    DriverProfile updateDeliverySearchRadius(Long driverId, Double deliverySearchRadius);
    String updateDriverAvailability(Long driverId, Boolean availability);
    String deleteAccount(Long driverId);


}
