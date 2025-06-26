package zw.co.kenac.takeu.backend.dto.waterdelivery.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ClientInformationDto {
    private Long clientId;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String email;
    private String gender;
    private String profilePhotoUrl;
}
