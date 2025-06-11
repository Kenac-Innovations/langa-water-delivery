package zw.co.kenac.takeu.backend.service.client;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.*;

import java.util.List;

public interface ClientDeliveryService {

    PaginatedResponse<ClientDeliveryResponse> findAllDeliveries(Long clientId, int pageNumber, int pageSize, String status);
    PaginatedResponse<ClientDeliveryResponse> getAllCustomerActiveDeliveries(Long clientId, int pageNumber, int pageSize);

    ClientDeliveryResponse findDeliveryById(Long deliveryId);

    ClientDeliveryResponse createDelivery(Long clientId, ClientDeliveryRequest deliveryRequest);

    String cancelDelivery(Long clientId, CancelDeliveryRequest request);

    String deleteDelivery(Long clientId, Long deliveryId);

    String selectDeliveryDriver(Long clientId, SelectDriverRequest request);

    String processPayment(Long clientId, DeliveryPaymentRequest paymentRequest);

    List<AvailableDriverResponse> findAvailableDrivers(Long deliveryId);
}
