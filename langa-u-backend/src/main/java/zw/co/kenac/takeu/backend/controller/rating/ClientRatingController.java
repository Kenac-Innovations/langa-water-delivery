package zw.co.kenac.takeu.backend.controller.rating;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.model.ClientRatingEntity;

import java.math.BigDecimal;
import java.util.List;

@Tag(name = "Client Rating Management")
@RequestMapping("${custom.base.path}/ratings/client")
public interface ClientRatingController {


    @PostMapping
    ResponseEntity<GenericResponse<String>> createRating(@RequestBody RatingDto ratingDto);

    @GetMapping("/client/{clientId}")
    ResponseEntity<GenericResponse<List<ClientRatingEntity>>> getRatingsByClientId(
            @PathVariable Long clientId);

    @GetMapping("/delivery/{deliveryId}")
    ResponseEntity<GenericResponse<ClientRatingEntity>> getRatingByDeliveryId(
            @PathVariable Long deliveryId);

    @GetMapping
    ResponseEntity<GenericResponse<List<ClientRatingEntity>>> getAllRatings();
    
    /**
     * Calculate average rating for a client
     * 
     * @param clientId Client's ID
     * @return Average rating value
     */
    @GetMapping("/average/{clientId}")
    ResponseEntity<GenericResponse<BigDecimal>> calculateAverageRating(
            @PathVariable Long clientId);
} 