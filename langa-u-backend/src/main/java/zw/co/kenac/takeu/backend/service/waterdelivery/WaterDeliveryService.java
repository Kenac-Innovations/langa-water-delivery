package zw.co.kenac.takeu.backend.service.waterdelivery;


import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
public interface WaterDeliveryService {
    PaginatedResponse<WaterDeliveryResponse> getDeliveriesByClient(Long clientId, String status, int pageNumber, int pageSize);

    PaginatedResponse<WaterDeliveryResponse> getDeliveriesByDriver(Long driverId,String status, int pageNumber, int pageSize);

    PaginatedResponse<WaterDeliveryResponse> getAllDeliveries(String status, int pageNumber, int pageSize);
    WaterDeliveryResponse getDeliveryById(Long deliveryId);
}
