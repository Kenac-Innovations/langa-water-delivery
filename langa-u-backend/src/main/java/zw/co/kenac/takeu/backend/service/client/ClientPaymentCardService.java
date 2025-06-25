package zw.co.kenac.takeu.backend.service.client;

import zw.co.kenac.takeu.backend.dto.client.ClientPaymentCardRequestDto;
import zw.co.kenac.takeu.backend.dto.client.ClientPaymentCardResponseDto;

import java.util.List;

/**
 * @author Joy Pedze
 * Date: 25 Jun 2025
 * Project: langa-u-backend
 * Package: zw.co.kenac.takeu.backend.service.client
 */

public interface ClientPaymentCardService {
    void createCard(ClientPaymentCardRequestDto dto);
    void updateCard(Long cardId, ClientPaymentCardRequestDto dto);
    void deleteCard(Long cardId);
    List<ClientPaymentCardResponseDto> getCardsByClient(Long clientId);
    void setDefaultCard(Long clientId, Long cardId);
}

