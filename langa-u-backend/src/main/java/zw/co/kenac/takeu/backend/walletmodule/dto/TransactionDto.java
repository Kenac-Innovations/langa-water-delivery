package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionDto {
    private String id;
    private TransactionType type;
    private BigDecimal principalAmount;
    private String paymentLink;
    private String pollUrl;
    private Long sourceWalletNumber;
    private Long destinationWalletNumber;
    private Long commissionWalletNumber;
    private BigDecimal commissionAmount;
    private String reference;
    private TransactionStatus status;
    private String narration;
    private Long clientId;
    private Long driverId;
    private Long organizationId;
    private PaymentMethod paymentMethod;
    private LocalDateTime createdDate;
}