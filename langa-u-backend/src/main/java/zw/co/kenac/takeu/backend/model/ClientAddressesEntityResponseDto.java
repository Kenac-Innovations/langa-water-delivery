package zw.co.kenac.takeu.backend.model;

import lombok.Builder;
import lombok.Value;

import java.io.Serializable;

/**
 * DTO for {@link ClientAddressesEntity}
 */
@Value
@Builder
public class ClientAddressesEntityResponseDto implements Serializable {
    Long entityId;
    String title;
    String addressEntered;
    Boolean isDefault;
    Long clientId;
    double latitude;
    double longitude;
    String addressFormatted;
    String geohash;
}