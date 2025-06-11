package zw.co.kenac.takeu.backend.dto.client;


import lombok.*;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 10/6/2025
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ClientAddressRequestDto {
    private String addressEntered;
    private double latitude;
    private double longitude;
    private String addressFormatted;
    private String geohash;
    private Long clientId;
}
