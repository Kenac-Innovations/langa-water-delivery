package zw.co.kenac.takeu.backend.dto.client;

public record CancelDeliveryRequest(
        Long deliveryId,
        String reason
) {
}
