package zw.co.kenac.takeu.backend.dto.client;

public record DeliveryPaymentRequest(
        Long deliveryId,
        String paymentMethod,
        String paymentStatus,
        String amountPaid
) { }
