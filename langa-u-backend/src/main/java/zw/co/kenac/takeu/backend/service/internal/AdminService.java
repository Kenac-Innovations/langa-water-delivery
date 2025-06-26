package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.SelectDriverRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryAdminResponse;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
public interface AdminService {
    PaginatedResponse<WaterDeliveryAdminResponse> getAllDeliveriesByStatus(DeliveryStatus status, int pageNumber, int pageSize);
    WaterDeliveryAdminResponse assignDeliveryToDriver(Long clientId, SelectDriverRequest request);
    WaterDeliveryAdminResponse unassignDeliveryFromDriver(Long deliveryId);
    //WaterDeliveryAdminResponse getDeliveryById(Long deliveryId);
}
