package zw.co.kenac.takeu.backend.controller.rating.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.rating.DriverRatingController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.model.DriverRatingEntity;
import zw.co.kenac.takeu.backend.service.internal.DriverRatingService;

import java.math.BigDecimal;
import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

/**
 * Implementation of driver rating controller
 */
@RestController
@RequiredArgsConstructor
@Slf4j
public class DriverRatingControllerImpl implements DriverRatingController {

    private final DriverRatingService driverRatingService;

    @Override
    public ResponseEntity<GenericResponse<String>> createRating(RatingDto ratingDto) {
        log.info("Creating driver rating for delivery ID: {}", ratingDto.deliveryId());
         driverRatingService.createRating(ratingDto);
        return ResponseEntity.ok(success("Rated Successfully"));
    }

    @Override
    public ResponseEntity<GenericResponse<List<DriverRatingEntity>>> getRatingsByDriverId(Long driverId) {
        log.info("Getting all ratings for driver ID: {}", driverId);
        List<DriverRatingEntity> ratings = driverRatingService.getRatingsByDriverId(driverId);
        return ResponseEntity.ok(success(ratings));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverRatingEntity>> getRatingByDeliveryId(Long deliveryId) {
        log.info("Getting rating for delivery ID: {}", deliveryId);
        DriverRatingEntity rating = driverRatingService.getRatingByDeliveryId(deliveryId);
        return ResponseEntity.ok(success(rating));
    }

    @Override
    public ResponseEntity<GenericResponse<List<DriverRatingEntity>>> getAllRatings() {
        log.info("Getting all driver ratings");
        List<DriverRatingEntity> ratings = driverRatingService.getAllRatings();
        return ResponseEntity.ok(success(ratings));
    }

    @Override
    public ResponseEntity<GenericResponse<BigDecimal>> calculateAverageRating(Long driverId) {
        log.info("Calculating average rating for driver ID: {}", driverId);
        BigDecimal averageRating = driverRatingService.calculateAverageRating(driverId);
        return ResponseEntity.ok(success(averageRating));
    }
} 