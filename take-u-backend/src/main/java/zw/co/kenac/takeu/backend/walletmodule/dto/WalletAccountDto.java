package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.*;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletCurrency;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * DTO for {@link zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount}
 */
@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder

@Value
public class WalletAccountDto implements Serializable {
    Long id;
    String accountNumber;
    WalletOwnerType ownerType;
    Long driverId;
    WalletAccountStatus status;
    WalletAccountType type;
    WalletCurrency currency;
    Long organizationId;
    LocalDateTime dateCreated;
    LocalDateTime lastUpdated;
}