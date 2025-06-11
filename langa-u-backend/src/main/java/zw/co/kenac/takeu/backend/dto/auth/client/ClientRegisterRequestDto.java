package zw.co.kenac.takeu.backend.dto.auth.client;


import lombok.*;
import zw.co.kenac.takeu.backend.dto.client.ClientAddressResponseDto;
import zw.co.kenac.takeu.backend.model.enumeration.CommChannels;

import java.util.List;

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
public class ClientRegisterRequestDto {
    private String phoneNumber;
    private String email;
    private String fullName;
    private List<CommChannels> commChannels;
    private ClientAddressResponseDto address;

    private String password;
    private String otp;
    private List<SecurityAnswerDto> securityAnswers;
}
