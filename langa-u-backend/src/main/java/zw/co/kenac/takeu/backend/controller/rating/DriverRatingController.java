package zw.co.kenac.takeu.backend.controller.rating;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.rating.RatingDto;
import zw.co.kenac.takeu.backend.model.DriverRatingEntity;

import java.math.BigDecimal;
import java.util.List;

@Tag(name = "Driver Rating Management")
@RequestMapping("${custom.base.path}/ratings/driver")
public interface DriverRatingController {


    @PostMapping
    ResponseEntity<GenericResponse<String>> createRating(@RequestBody RatingDto ratingDto);
    

    @GetMapping("/driver/{driverId}")
    ResponseEntity<GenericResponse<List<DriverRatingEntity>>> getRatingsByDriverId(
            @PathVariable Long driverId);
    

    @GetMapping("/delivery/{deliveryId}")
    ResponseEntity<GenericResponse<DriverRatingEntity>> getRatingByDeliveryId(
            @PathVariable Long deliveryId);
    

    @GetMapping
    ResponseEntity<GenericResponse<List<DriverRatingEntity>>> getAllRatings();
    

    @GetMapping("/average/{driverId}")
    ResponseEntity<GenericResponse<BigDecimal>> calculateAverageRating(
            @PathVariable Long driverId);
} 