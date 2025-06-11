package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/27/2025
 */

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TransactionCreateResponseDTO {
    private String transactionId;
    private String transactionType;
    private String paymentLink;

}
