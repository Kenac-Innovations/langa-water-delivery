package zw.co.kenac.takeu.backend.dto.rating;

import java.math.BigDecimal;
import java.util.Set;

/**
 * Data Transfer Object for ratings
 */
public record RatingDto(
    Long id,
    BigDecimal rating,
    Set<String> comments,
    Long clientId,
    Long driverId,
    Long deliveryId
) {} 