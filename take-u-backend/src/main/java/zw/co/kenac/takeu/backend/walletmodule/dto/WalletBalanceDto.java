package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.*;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletBalance;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder
@Value
public class WalletBalanceDto implements Serializable {
    String id;
    Long amount;
    Long runningBalance;
    String transactionRef;
    Transaction transaction;
    LocalDateTime dateCreated;
    Long walletId;
}