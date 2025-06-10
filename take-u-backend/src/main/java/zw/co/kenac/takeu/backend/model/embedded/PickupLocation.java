package zw.co.kenac.takeu.backend.model.embedded;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
public class PickupLocation {
    private Double pickupLatitude;

    private Double pickupLongitude;

    private String pickupLocation;

    private String pickupContactName;

    private String pickupContactPhone;
}
