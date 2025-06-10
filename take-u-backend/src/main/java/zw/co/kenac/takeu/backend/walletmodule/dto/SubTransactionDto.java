package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.*;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionEntryType;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO for {@link zw.co.kenac.takeu.backend.walletmodule.models.SubTransaction}
 */
@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder
@Value
public class SubTransactionDto implements Serializable {
    Long id;
    Long walletId;
    String reference;
    Long currencyId;
    String transactionId;
    PaymentMethod paymentMethod;
    TransactionEntryType type;
    BigDecimal amount;
    LocalDateTime dateCreated;
    LocalDateTime dateUpdate;
}