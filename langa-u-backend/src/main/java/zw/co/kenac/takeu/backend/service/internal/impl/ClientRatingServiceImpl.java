package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.ClientRatingEntity;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.repository.ClientRatingRepository;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.service.internal.ClientRatingService;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

/**
 * Implementation of client rating service
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ClientRatingServiceImpl implements ClientRatingService {

    private final ClientRatingRepository clientRatingRepository;
    private final ClientRepository clientRepository;
    private final DeliveryRepository deliveryRepository;
@Async
    @Override
    public CompletableFuture<Void> createRating(RatingDto ratingDto) {
        log.info("Creating client rating for delivery ID: {}", ratingDto.deliveryId());
        
        // Find the client
        ClientEntity client = clientRepository.findById(ratingDto.clientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with ID: " + ratingDto.clientId()));
        

        DeliveryEntity delivery = deliveryRepository.findById(ratingDto.deliveryId())
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found with ID: " + ratingDto.deliveryId()));

        Optional<ClientRatingEntity> existingRating = clientRatingRepository.findAll().stream()
                .filter(rating -> rating.getDelivery().getEntityId().equals(ratingDto.deliveryId()))
                .findFirst();
        
        if (existingRating.isEmpty()) {
            // Create a new rating
            ClientRatingEntity rating = new ClientRatingEntity();
            rating.setRating(ratingDto.rating());
            rating.setComments(ratingDto.comments() != null ? ratingDto.comments() : new HashSet<>());
            rating.setClient(client);
            rating.setDelivery(delivery);
            
           clientRatingRepository.save(rating);
        }
        
        return CompletableFuture.completedFuture(null);
    }

    @Override
    public List<ClientRatingEntity> getRatingsByClientId(Long clientId) {
        log.info("Getting all ratings for client ID: {}", clientId);
        return clientRatingRepository.findAllByClientId(clientId);
    }

    @Override
    public ClientRatingEntity getRatingByDeliveryId(Long deliveryId) {
        log.info("Getting rating for delivery ID: {}", deliveryId);
        return clientRatingRepository.findAll().stream()
                .filter(rating -> rating.getDelivery().getEntityId().equals(deliveryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found for delivery ID: " + deliveryId));
    }

    @Override
    public List<ClientRatingEntity> getAllRatings() {
        log.info("=======> Getting all client ratings");
        return clientRatingRepository.findAll();
    }

    @Override
    public BigDecimal calculateAverageRating(Long clientId) {
        log.info("==========> Calculating average rating for client ID: {}", clientId);
        Optional<BigDecimal> ratings = clientRatingRepository.findClientAverageRating(clientId);
        
        if (ratings.isEmpty()) {
            log.info("========> No ratings found for client ID: {}", clientId);
            return BigDecimal.ZERO;
        }
        return ratings.get();
    }
} 