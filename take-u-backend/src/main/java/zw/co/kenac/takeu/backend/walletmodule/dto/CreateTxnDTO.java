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
 * Created on: 4/26/2025
 */

@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder
public class CreateTxnDTO {
    private Long clientId;
    private Long driverId;
    private Long deliveryId;
    private Long currencyId;
    private PaymentMethod paymentMethod;
    private BigDecimal principal;
    private BigDecimal calculatedCommission;
    private String phoneNumber;
    

    public BigDecimal getCalculatedCommission() {
        return calculatedCommission;
    }
    

    public void setCalculatedCommission(BigDecimal commission) {
        this.calculatedCommission = commission;
    }
}
