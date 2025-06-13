package zw.co.kenac.takeu.backend.dto.auth.client;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
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

    @NotBlank(message = "Phone number is required")
    private String phoneNumber;

    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Full name is required")
    private String fullName;

    @NotEmpty(message = "At least one communication channel is required")
    private List<CommChannels> commChannels;

    private ClientAddressResponseDto address;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters long")
    private String password;



    @NotEmpty(message = "At least one security answer is required")
    private List<SecurityAnswerDto> securityAnswers;
}