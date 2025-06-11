package zw.co.kenac.takeu.backend.service.driver;

import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleResponse;

import java.util.List;

public interface DriverVehicleService {

    List<DriverVehicleResponse> findAllVehicles(Long driverId);

    DriverVehicleResponse findVehicleById(Long driverId, Long vehicleId);

    DriverVehicleResponse createVehicle(Long driverId, DriverVehicleRequest request);

    DriverVehicleResponse updateVehicle(Long driverId, Long vehicleId, DriverVehicleRequest request);

    String deleteVehicle(Long driverId, Long vehicleId);

    String switchVehicle(Long driverId, Long vehicleId);
}
