package zw.co.kenac.takeu.backend.controller.rating.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.rating.ClientRatingController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.model.ClientRatingEntity;
import zw.co.kenac.takeu.backend.service.internal.ClientRatingService;

import java.math.BigDecimal;
import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

/**
 * Implementation of client rating controller
 */
@RestController
@RequiredArgsConstructor
@Slf4j
public class ClientRatingControllerImpl implements ClientRatingController {

    private final ClientRatingService clientRatingService;

    @Override
    public ResponseEntity<GenericResponse<String>> createRating(RatingDto ratingDto) {
        log.info("Creating client rating for delivery ID: {}", ratingDto.deliveryId());
      clientRatingService.createRating(ratingDto);
        return ResponseEntity.ok(success("Rating has been created successfully"));
    }

    @Override
    public ResponseEntity<GenericResponse<List<ClientRatingEntity>>> getRatingsByClientId(Long clientId) {
        log.info("Getting all ratings for client ID: {}", clientId);
        List<ClientRatingEntity> ratings = clientRatingService.getRatingsByClientId(clientId);
        return ResponseEntity.ok(success(ratings));
    }

    @Override
    public ResponseEntity<GenericResponse<ClientRatingEntity>> getRatingByDeliveryId(Long deliveryId) {
        log.info("Getting rating for delivery ID: {}", deliveryId);
        ClientRatingEntity rating = clientRatingService.getRatingByDeliveryId(deliveryId);
        return ResponseEntity.ok(success(rating));
    }

    @Override
    public ResponseEntity<GenericResponse<List<ClientRatingEntity>>> getAllRatings() {
        log.info("Getting all client ratings");
        List<ClientRatingEntity> ratings = clientRatingService.getAllRatings();
        return ResponseEntity.ok(success(ratings));
    }

    @Override
    public ResponseEntity<GenericResponse<BigDecimal>> calculateAverageRating(Long clientId) {
        log.info("Calculating average rating for client ID: {}", clientId);
        BigDecimal averageRating = clientRatingService.calculateAverageRating(clientId);
        return ResponseEntity.ok(success(averageRating));
    }
} 