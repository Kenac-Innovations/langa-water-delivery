package zw.co.kenac.takeu.backend.dto.auth.client;

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
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ClientProfileResponse {
    private Long userId;
    private String email;
    private String phoneNumber;
    private String firstName;

    private Boolean isCreditedAllowed;
    }
