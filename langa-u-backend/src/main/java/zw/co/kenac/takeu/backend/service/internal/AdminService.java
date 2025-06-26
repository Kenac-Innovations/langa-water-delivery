package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.ClientDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
public interface AdminService {
    PaginatedResponse<DriverDeliveryResponse> getAllDeliveriesByStatus(DeliveryStatus status, int pageNumber, int pageSize);
}
