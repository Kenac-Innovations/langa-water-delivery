package zw.co.kenac.takeu.backend.dto.auth.driver;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 9/4/2025
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DriverProfileResponse {
    private Long driverID;
    private String email;
    private String phoneNumber;
    private String firstname;
    private String lastname;
    private String gender;
    private String address;
    private String profilePhotoUrl;
    private String nationalIdNumber;
    private BigDecimal walletBalance;
    private Double rating;
    private Long walletId;
    private Boolean onlineStatus;
    private Double searchRadiusInKm;
}