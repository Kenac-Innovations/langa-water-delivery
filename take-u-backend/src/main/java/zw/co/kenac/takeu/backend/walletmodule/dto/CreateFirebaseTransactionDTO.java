package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateFirebaseTransactionDTO {
    private String transactionId;
    private String reference;
    private BigDecimal amount;
    private TransactionStatus status;
    private String narration;
    private String paymentMethod;
    private String currency;
    private String clientId;
    private String driverId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 