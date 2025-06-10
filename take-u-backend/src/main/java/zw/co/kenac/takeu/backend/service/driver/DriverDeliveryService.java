package zw.co.kenac.takeu.backend.service.driver;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.driver.*;

import java.io.IOException;

public interface DriverDeliveryService {
    PaginatedResponse<DriverDeliveryResponse> findAllDeliveries( int pageNumber, int pageSize, String status);

    PaginatedResponse<DriverDeliveryResponse> findAllDriverDeliveries(Long driverId, String status, int pageNumber, int pageSize);// this can be used to get driver history by just getting the completed
    PaginatedResponse<DriverDeliveryResponseWithProposal> findAllOpenDeliveriesByVehicleType(Long driverId, String status, String vehicleType, int pageNumber, int pageSize);
    PaginatedResponse<DriverDeliveryResponse> findAllDriverAssignedDelivery(Long driverId ,int pageNumber, int pageSize);

    DriverDeliveryResponse findDeliveryById(Long deliveryId);

    String proposeDelivery(Long deliveryId, DriverPromptRequest request);

    String acceptDelivery(Long deliveryId, DriverPromptRequest request);

    String cancelDelivery(Long deliveryId, DriverPromptRequest request);

    String pickupDelivery(Long deliveryId, PickupDeliveryRequest request) throws IOException;

    String completeDelivery(Long deliveryId, CompleteDeliveryRequest request);

    String deleteProposal(Long deliveryId, DriverPromptRequest request);
}
