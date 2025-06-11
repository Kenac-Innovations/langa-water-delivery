package zw.co.kenac.takeu.backend.dto.auth.client;


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
public class OtpVerificationDto {
    private String otp;
    private String phoneOrEmail;
}
