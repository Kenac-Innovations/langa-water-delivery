package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionType;

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
public class DriverWalletTransactionResponseDTO {
    private String transactionId;
    private Long driverId;
    private BigDecimal amount;
    private String currencyCode;
    private TransactionType type;
    private TransactionStatus status;
    private String reference;
    private String paymentLink; // For payment gateway integrations, if needed
} 