package zw.co.kenac.takeu.backend.controller.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.internal.AuthController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.LoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterRequest;
import zw.co.kenac.takeu.backend.service.internal.AuthService;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
@RestController
@RequiredArgsConstructor
public class AuthControllerImpl implements AuthController {

    private final AuthService authService;

    @Override
    public ResponseEntity<GenericResponse<LoginResponse>> login(LoginRequest loginRequest) {
        return ResponseEntity.ok(success(authService.login(loginRequest)));
    }

    @Override
    public void verifyAccount(VerifyAccountRequest verifyEmail) {

    }

    @Override
    public void logout() {

    }

    @Override
    public void requestPasswordLink() {

    }

    @Override
    public void resetPassword() {

    }
}
