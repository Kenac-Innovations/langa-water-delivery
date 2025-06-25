package zw.co.kenac.takeu.backend.dto.client;

import lombok.*;

/**
 * @author Joy Pedze
 * Date: 25 Jun 2025
 * Project: langa-u-backend
 * Package: zw.co.kenac.takeu.backend.dto.client
 */

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientPaymentCardResponseDto {
    private Long id;
    private String cardHolderName;
    private String maskedCardNumber;
    private String expiryDate;
    private String cardType;
    private Boolean isDefault;
}
