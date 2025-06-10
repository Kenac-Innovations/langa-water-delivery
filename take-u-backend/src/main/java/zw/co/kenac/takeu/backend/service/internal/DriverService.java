package zw.co.kenac.takeu.backend.service.internal;

import org.springframework.http.ResponseEntity;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.dto.driver.ReviewDriverProfileDto;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
public interface DriverService {

    PaginatedResponse<DriverProfile> findAllDrivers(int pageNumber, int pageSize, String status);

    DriverProfile findDriverById(Long driverId);

    String approveDriver(Long driverId, DriverApprovalRequest request);

    String deleteDriver(Long driverId);
    DriverEntity reviewDriverProfile(ReviewDriverProfileDto reviewDriverProfileDto);
}
