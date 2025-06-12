package zw.co.kenac.takeu.backend.service.waterdelivery;

import zw.co.kenac.takeu.backend.dto.waterdelivery.request.WaterOrderCreateRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;

import java.util.List;

/**
 * Service for managing water orders.
 */
public interface WaterOrderService {

    /**
     * Creates a new water order.
     *
     * @param request The request DTO containing order details.
     * @return The created order details.
     */
    WaterOrderResponse createOrder(WaterOrderCreateRequestDto request);

    WaterOrderResponse getOrderById(Long orderId);

    List<WaterOrderResponse> getOrdersByClient(Long clientId);

    List<WaterOrderResponse> getOrdersByDriver(Long driverId);

    List<WaterOrderResponse> getAllOrders();
} 