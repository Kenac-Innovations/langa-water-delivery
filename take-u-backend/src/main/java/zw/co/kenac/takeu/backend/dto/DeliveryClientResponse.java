package zw.co.kenac.takeu.backend.dto;

public record DeliveryClientResponse(
        Long clientId,
        String firstname,
        String lastname,
        String mobileNumber,
        String emailAddress
) { }
