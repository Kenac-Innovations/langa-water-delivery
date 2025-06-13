package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.model.DriverRatingEntity;

import java.math.BigDecimal;
import java.util.List;
import java.util.concurrent.CompletableFuture;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
public interface DriverRatingService {
    

    CompletableFuture<Void> createRating(RatingDto ratingDto);
    

    List<DriverRatingEntity> getRatingsByDriverId(Long driverId);
    

    DriverRatingEntity getRatingByDeliveryId(Long deliveryId);
    

    List<DriverRatingEntity> getAllRatings();
    

    BigDecimal calculateAverageRating(Long driverId);
} 