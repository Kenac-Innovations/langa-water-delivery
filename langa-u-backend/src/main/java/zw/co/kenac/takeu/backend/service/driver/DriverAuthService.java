package zw.co.kenac.takeu.backend.service.driver;

import zw.co.kenac.takeu.backend.dto.auth.PasswordLinkRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordResetRequest;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;

import java.io.IOException;

public interface DriverAuthService {

    DriverLoginResponse login(LoginRequest loginRequest);

    DriverRegisterResponse register(DriverRegisterRequest registerRequest) throws IOException;

    String verifyAccount(VerifyAccountRequest request);
    boolean validateResetToken(String token);

    String requestPasswordLink(PasswordLinkRequest request);

    String resetPassword(PasswordResetRequest request);

}
