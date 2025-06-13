package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 5/14/2025
 */
@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder
public class CompleteTransactionDTO {
    private String transactionId;
    private TransactionStatus status;
    private String narration;
} 