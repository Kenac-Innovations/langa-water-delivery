package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.*;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;

import java.io.Serializable;
import java.util.Date;

/**
 * DTO for {@link zw.co.kenac.takeu.backend.walletmodule.models.Currencies}
 */
@Data
@NoArgsConstructor(force = true)
@AllArgsConstructor
@Builder
@Value
public class CurrenciesDto implements Serializable {
    Long id;
    String name;
    String alphaCode;
    String numericCode;
    WalletAccountStatus status;
    Date dateCreated;
}