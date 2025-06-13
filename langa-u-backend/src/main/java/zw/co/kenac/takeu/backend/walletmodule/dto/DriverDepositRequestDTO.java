package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;

import java.math.BigDecimal;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 5/14/2025
 */
@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder
public class DriverDepositRequestDTO {
    private Long driverId;
    private BigDecimal amount;
    private Long currencyId;
    private String phoneNumber;
    private PaymentMethod paymentMethod;
} 