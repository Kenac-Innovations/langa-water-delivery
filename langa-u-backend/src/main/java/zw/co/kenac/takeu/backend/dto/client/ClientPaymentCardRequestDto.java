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
public class ClientPaymentCardRequestDto {
    private Long clientId;
    private String cardHolderName;
    private String cardNumber;
    private String expiryDate;
    private String cardType;
}
