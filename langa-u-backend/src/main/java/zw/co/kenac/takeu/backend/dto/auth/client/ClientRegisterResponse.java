package zw.co.kenac.takeu.backend.dto.auth.client;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 8/4/2025
 */
public record ClientRegisterResponse(
        Long userId,
        String email,
        String phoneNumber
) { }
