package zw.co.kenac.takeu.backend.service.client.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.client.ClientPaymentCardRequestDto;
import zw.co.kenac.takeu.backend.dto.client.ClientPaymentCardResponseDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.waterdelivery.ClientPaymentCardEntity;
import zw.co.kenac.takeu.backend.repository.ClientPaymentCardRepository;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.service.client.ClientPaymentCardService;

import java.util.List;

/**
 * @author Joy Pedze
 * Date: 25 Jun 2025
 * Project: langa-u-backend
 * Package: zw.co.kenac.takeu.backend.service.client.impl
 */

@Service
@RequiredArgsConstructor
public class ClientPaymentCardServiceImpl implements ClientPaymentCardService {
    private final ClientPaymentCardRepository cardRepository;
    private final ClientRepository clientRepository;

    @Override
    public void createCard(ClientPaymentCardRequestDto dto) {
        ClientEntity client = clientRepository.findById(dto.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client not found"));

        ClientPaymentCardEntity entity = ClientPaymentCardEntity.builder()
                .cardHolderName(dto.getCardHolderName())
                .cardNumber(dto.getCardNumber())
                .expiryDate(dto.getExpiryDate())
                .cardType(dto.getCardType())
                .isDefault(false)
                .client(client)
                .build();

        cardRepository.save(entity);
    }

    @Override
    public void updateCard(Long cardId, ClientPaymentCardRequestDto dto) {
        ClientPaymentCardEntity entity = cardRepository.findById(cardId)
                .orElseThrow(() -> new ResourceNotFoundException("Card not found"));

        entity.setCardHolderName(dto.getCardHolderName());
        entity.setCardNumber(dto.getCardNumber());
        entity.setExpiryDate(dto.getExpiryDate());
        entity.setCardType(dto.getCardType());

        cardRepository.save(entity);
    }

    @Override
    public void deleteCard(Long cardId) {
        cardRepository.deleteById(cardId);
    }

    @Override
    public List<ClientPaymentCardResponseDto> getCardsByClient(Long clientId) {
        return cardRepository.findByClient_EntityId(clientId).stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public void setDefaultCard(Long clientId, Long cardId) {
        List<ClientPaymentCardEntity> cards = cardRepository.findByClient_EntityId(clientId);

        for (ClientPaymentCardEntity card : cards) {
            card.setIsDefault(card.getEntityId().equals(cardId));
        }

        cardRepository.saveAll(cards);
    }

    private ClientPaymentCardResponseDto toDto(ClientPaymentCardEntity entity) {
        return ClientPaymentCardResponseDto.builder()
                .id(entity.getEntityId())
                .cardHolderName(entity.getCardHolderName())
                .maskedCardNumber("**** **** **** " + entity.getCardNumber().substring(entity.getCardNumber().length() - 4))
                .expiryDate(entity.getExpiryDate())
                .cardType(entity.getCardType())
                .isDefault(entity.getIsDefault())
                .build();
    }
}
