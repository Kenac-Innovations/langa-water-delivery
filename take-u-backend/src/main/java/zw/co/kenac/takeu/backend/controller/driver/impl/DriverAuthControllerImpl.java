package zw.co.kenac.takeu.backend.controller.driver.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.driver.DriverAuthController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordLinkRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordResetRequest;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterResponse;
import zw.co.kenac.takeu.backend.repository.PasswordResetTokenRepository;
import zw.co.kenac.takeu.backend.service.driver.DriverAuthService;

import java.io.IOException;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class DriverAuthControllerImpl implements DriverAuthController {

    private final DriverAuthService driverAuthService;
    private final PasswordResetTokenRepository passwordResetTokenRepository;

    @Override
    public ResponseEntity<GenericResponse<DriverLoginResponse>> login(LoginRequest loginRequest) {
        DriverLoginResponse driverLoginResponse = driverAuthService.login(loginRequest);
        return ResponseEntity.ok(success(driverLoginResponse));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverRegisterResponse>> register(DriverRegisterRequest registerRequest) throws IOException {
        DriverRegisterResponse driverRegisterResponse = driverAuthService.register(registerRequest);
        return ResponseEntity.ok(success(driverRegisterResponse));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> verifyAccount(VerifyAccountRequest request) {
        return ResponseEntity.ok(success(driverAuthService.verifyAccount(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> requestPasswordLink(PasswordLinkRequest request) {
        return ResponseEntity.ok(success(driverAuthService.requestPasswordLink(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> resetPassword(PasswordResetRequest request) {
        return ResponseEntity.ok(success(driverAuthService.resetPassword(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> validateResetToken(String token) {
        boolean isValid = driverAuthService.validateResetToken(token);
        if (isValid) {
            return ResponseEntity.ok(success("Token is valid"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(GenericResponse.<String>error());
        }
    }

}
