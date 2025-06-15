package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.*;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverProfileResponse;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 8/4/2025
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LoginResponseDto {
    private String accessToken;
    private String refreshToken;
    private String userType;
    private Long userID;
    private ClientProfileResponse userProfile;
    private DriverProfileResponse driverProfile;
}