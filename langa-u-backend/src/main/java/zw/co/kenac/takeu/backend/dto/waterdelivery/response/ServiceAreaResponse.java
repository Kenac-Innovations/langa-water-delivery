package zw.co.kenac.takeu.backend.dto.waterdelivery.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceAreaResponse {
    private Long id;
    private String name;
    private Double latitude;
    private Double longitude;
    private Double radiusKm;
    private String geohash;
    private Boolean active;
    private String description;

}
