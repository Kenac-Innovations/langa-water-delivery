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
public class DropOffLocation {
    private Double dropOffLatitude;

    private Double dropOffLongitude;

    private String dropOffLocation;

    private String dropOffContactName;

    private String dropOffContactPhone;
}
