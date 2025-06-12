package zw.co.kenac.takeu.backend.dto.waterdelivery.request;

import lombok.Builder;
import lombok.Value;

import java.io.Serializable;

/**
 * DTO for {@link zw.co.kenac.takeu.backend.model.embedded.DropOffLocation}
 */
@Value
@Builder
public class DropOffLocationRequestDto implements Serializable {
    Double dropOffLatitude;
    Double dropOffLongitude;
    String dropOffLocation;
    String dropOffAddressType;
    String dropOffContactName;
    String dropOffContactPhone;
}