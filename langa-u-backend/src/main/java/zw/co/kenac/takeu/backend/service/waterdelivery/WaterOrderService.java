package zw.co.kenac.takeu.backend.service.waterdelivery;

import zw.co.kenac.takeu.backend.dto.waterdelivery.request.CreateWaterOrderRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;

public interface WaterOrderService {
    /**
     * Create a new water order
     * @param request The order creation request
     * @return The created order details
     */
    WaterOrderResponse createOrder(CreateWaterOrderRequest request);
} 