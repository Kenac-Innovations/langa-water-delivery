package zw.co.kenac.takeu.backend.model.embedded;


import jakarta.persistence.Embeddable;
import lombok.*;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 27/5/2025
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Embeddable
public class VehicleDocument {
    private String frontImageUrl;
    private String backImageUrl;
    private String sideImageUrl;
    private String registrationBookUrl;
}
