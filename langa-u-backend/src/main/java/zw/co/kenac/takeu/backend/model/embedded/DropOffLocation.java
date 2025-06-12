package zw.co.kenac.takeu.backend.model.embedded;

import jakarta.persistence.Embeddable;
import lombok.*;

@Getter
@Setter
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DropOffLocation {
    private Double dropOffLatitude;
    private Double dropOffLongitude;
    private String dropOffLocation;
    private String dropOffAddressType;
    private String dropOffContactName;
    private String dropOffContactPhone;
}
