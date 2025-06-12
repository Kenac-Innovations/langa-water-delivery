package zw.co.kenac.takeu.backend.service.waterdelivery;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
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

    PaginatedResponse<WaterOrderResponse> getOrdersByClient(Long clientId,String status, int pageNumber, int pageSize);

   // PaginatedResponse<WaterOrderResponse> getOrdersByDriver(Long driverId,String status, int pageNumber, int pageSize);

    PaginatedResponse<WaterOrderResponse> getAllOrders(String status, int pageNumber, int pageSize);
} 