package zw.co.kenac.takeu.backend.dto.client;

import java.math.BigDecimal;

public record PriceRequest(
        String vehicleType,
        String currency,
        String sensitivity,
        BigDecimal distance
) { }
