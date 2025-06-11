package zw.co.kenac.takeu.backend.service.client;

import zw.co.kenac.takeu.backend.dto.auth.*;
import zw.co.kenac.takeu.backend.dto.auth.client.*;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 8/4/2025
 */
public interface ClientAuthService {

    ClientLoginResponse login(LoginRequest loginRequest);

    ClientRegisterResponse register(ClientRegisterRequest request);
    ClientLoginResponse registerClient(ClientRegisterRequestDto requestDto);

    Boolean verifyAccountOtp(OtpVerificationDto otpVerificationDto);

    String verifyAccount(VerifyAccountRequest request);
    boolean validateResetToken(String token);

    String requestPasswordLink(PasswordLinkRequest request);

    String resetPassword(PasswordResetRequest request);

    void requestOtp(OtpRequest otpRequest);
}
