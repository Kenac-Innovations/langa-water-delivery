package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.internal.SuspendRequest;
import zw.co.kenac.takeu.backend.dto.internal.VehicleResponse;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
public interface VehicleService {

    PaginatedResponse<VehicleResponse> findAllVehicles(int pageNumber, int pageSize, String vehicleType);

    PaginatedResponse<VehicleResponse> findVehiclesByDriver(Long driverId, int pageNumber, int pageSize);

    VehicleResponse findVehicleById(Long vehicleId);

    String approveVehicle(Long vehicleId, DriverApprovalRequest request);

    String suspendVehicle(Long vehicleId, SuspendRequest request);

}
