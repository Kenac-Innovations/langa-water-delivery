package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.model.ClientRatingEntity;

import java.math.BigDecimal;
import java.util.List;
import java.util.concurrent.CompletableFuture;

/**
 * Service for client ratings management
 */
public interface ClientRatingService {
    

    CompletableFuture<Void> createRating(RatingDto ratingDto);

    List<ClientRatingEntity> getRatingsByClientId(Long clientId);

    ClientRatingEntity getRatingByDeliveryId(Long deliveryId);

    List<ClientRatingEntity> getAllRatings();

    BigDecimal calculateAverageRating(Long clientId);
} 