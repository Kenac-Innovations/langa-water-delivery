package zw.co.kenac.takeu.backend.service.internal.impl;

import com.google.type.Decimal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.DriverRatingEntity;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.repository.DriverRatingRepository;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.service.internal.DriverRatingService;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

/**
 * Implementation of driver rating service
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class DriverRatingServiceImpl implements DriverRatingService {

    private final DriverRatingRepository driverRatingRepository;
    private final DriverRepository driverRepository;
    private final DeliveryRepository deliveryRepository;
@Async
    @Override
    public CompletableFuture<Void> createRating(RatingDto ratingDto) {
        log.info("Creating driver rating for delivery ID: {}", ratingDto.deliveryId());
        
        // Find the driver
        DriverEntity driver = driverRepository.findById(ratingDto.driverId())
                .orElseThrow(() -> new ResourceNotFoundException("Driver not found with ID: " + ratingDto.driverId()));
        
        // Find the delivery
        DeliveryEntity delivery = deliveryRepository.findById(ratingDto.deliveryId())
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found with ID: " + ratingDto.deliveryId()));
        
        // Check if a rating already exists for this delivery
        Optional<DriverRatingEntity> existingRating = driverRatingRepository.findAll().stream()
                .filter(rating -> rating.getDelivery().getEntityId().equals(ratingDto.deliveryId()))
                .findFirst();
        
        if (existingRating.isEmpty())  {
            // Create a new rating
            DriverRatingEntity rating = new DriverRatingEntity();
            rating.setRating(ratingDto.rating());
            rating.setComments(ratingDto.comments() != null ? ratingDto.comments() : new HashSet<>());
            rating.setDriver(driver);
            rating.setDelivery(delivery);
            
            driverRatingRepository.save(rating);
        }
        
        return CompletableFuture.completedFuture(null);
    }

    @Override
    public List<DriverRatingEntity> getRatingsByDriverId(Long driverId) {
        log.info("Getting all ratings for driver ID: {}", driverId);
        return driverRatingRepository.findAllByDriverId(driverId);
    }

    @Override
    public DriverRatingEntity getRatingByDeliveryId(Long deliveryId) {
        log.info("Getting rating for delivery ID: {}", deliveryId);
        return driverRatingRepository.findAll().stream()
                .filter(rating -> rating.getDelivery().getEntityId().equals(deliveryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found for delivery ID: " + deliveryId));
    }

    @Override
    public List<DriverRatingEntity> getAllRatings() {
        log.info("Getting all driver ratings");
        return driverRatingRepository.findAll();
    }

    @Override
    public BigDecimal calculateAverageRating(Long driverId) {
        log.info("Calculating average rating for driver ID: {}", driverId);
        List<DriverRatingEntity> ratings = driverRatingRepository.findAllByDriverId(driverId);
        Optional<BigDecimal> averageRatingOptional = driverRatingRepository.findAverageRatingByDriverIdOptional(driverId);

        if (averageRatingOptional.isEmpty()) {
            log.info("No ratings found for driver ID: {}", driverId);
            return BigDecimal.ZERO;
        }
        return averageRatingOptional.get();
    }
} 