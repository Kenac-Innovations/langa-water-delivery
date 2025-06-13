package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.auth.*;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
public interface AuthService {

    LoginResponse login(LoginRequest loginRequest);

    String verifyAccount(VerifyAccountRequest request);

    String requestPasswordLink(PasswordLinkRequest request);

    String resetPassword(PasswordResetRequest request);

}
