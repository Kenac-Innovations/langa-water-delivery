package zw.co.kenac.takeu.backend.dto.auth.client;

import java.math.BigDecimal;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 9/4/2025
 */
public record ClientProfileResponse(
        Long userId,
        String email,
        String phoneNumber,
        String firstName,
        String lastName,
        BigDecimal walletBalance
) { }
