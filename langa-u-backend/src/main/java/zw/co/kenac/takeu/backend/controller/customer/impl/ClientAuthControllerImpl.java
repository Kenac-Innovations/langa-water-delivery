package zw.co.kenac.takeu.backend.controller.customer.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.controller.customer.ClientAuthController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordLinkRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordResetRequest;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterResponse;
import zw.co.kenac.takeu.backend.service.client.ClientAuthService;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class ClientAuthControllerImpl implements ClientAuthController {

    private final ClientAuthService clientAuthService;

    @Override
    public ResponseEntity<GenericResponse<ClientLoginResponse>> login(LoginRequest loginRequest) {
        ClientLoginResponse response = clientAuthService.login(loginRequest);
        return ResponseEntity.ok(success(response));
    }

    @Override
    public ResponseEntity<GenericResponse<ClientRegisterResponse>> register(ClientRegisterRequest registerRequest) {
        ClientRegisterResponse response = clientAuthService.register(registerRequest);
        return ResponseEntity.ok(success(response));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> verifyAccount(VerifyAccountRequest request) {
        return ResponseEntity.ok(success(clientAuthService.verifyAccount(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> requestPasswordLink(PasswordLinkRequest request) {
        return ResponseEntity.ok(success(clientAuthService.requestPasswordLink(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> resetPassword(PasswordResetRequest request) {
        return ResponseEntity.ok(success(clientAuthService.resetPassword(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> validateResetToken(String token) {
        boolean isValid = clientAuthService.validateResetToken(token);
        if (isValid) {
            return ResponseEntity.ok(success("Token is valid"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(GenericResponse.<String>error());
        }
    }

}
