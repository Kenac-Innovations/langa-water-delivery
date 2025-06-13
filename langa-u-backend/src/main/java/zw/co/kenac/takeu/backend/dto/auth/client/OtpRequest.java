package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OtpRequest {
    private String email;
    private String phoneNumber;
    private String fullName;
} 