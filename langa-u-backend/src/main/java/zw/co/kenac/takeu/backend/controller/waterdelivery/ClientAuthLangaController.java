package zw.co.kenac.takeu.backend.controller.waterdelivery;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterRequestDto;
import zw.co.kenac.takeu.backend.dto.auth.client.NewPasswordRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.OtpRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.OtpVerificationDto;
import zw.co.kenac.takeu.backend.dto.auth.client.PasswordResetOtpRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.PasswordResetOtpVerifyRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.SecurityChallengeRequest;
import zw.co.kenac.takeu.backend.service.client.ClientAuthService;

@RestController
@RequestMapping("/api/v2/auth")
@RequiredArgsConstructor
@Tag(name = "Client Auth", description = "Endpoints for client authentication and registration")
public class ClientAuthLangaController {

    private final ClientAuthService clientAuthService;

    @Operation(summary = "Request OTP for client registration or login")
    @PostMapping("/request-otp")
    public ResponseEntity<GenericResponse<?>> requestOtp(@RequestBody OtpRequest otpRequest) {
        clientAuthService.requestOtp(otpRequest);
        return ResponseEntity.ok(GenericResponse.success("OTP sent to your phone number or email"));
    }

    @Operation(summary = "Register a new client using OTP verification")
    @PostMapping("/register")
    public ResponseEntity<GenericResponse<ClientLoginResponse>> registerClient(
            @RequestBody ClientRegisterRequestDto requestDto) {
        return ResponseEntity.ok(GenericResponse.success(clientAuthService.registerClient(requestDto)));
    }

    @Operation(summary = "Validate OTP to activate client account")
    @PostMapping("/validate-otp")
    public ResponseEntity<GenericResponse<Boolean>> validateOtp(@RequestBody OtpVerificationDto requestDto) {
        return ResponseEntity.ok(GenericResponse.success(clientAuthService.verifyAccountOtp(requestDto)));
    }

    @Operation(summary = "Login existing client using phone and password")
    @PostMapping("/login")
    public ResponseEntity<GenericResponse<ClientLoginResponse>> login(@RequestBody LoginRequest loginRequest) {
        ClientLoginResponse response = clientAuthService.login(loginRequest);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @PostMapping("/password/request-reset-otp")
    public ResponseEntity<?> requestPasswordResetOtp(@RequestBody PasswordResetOtpRequest request) {
        return ResponseEntity.ok(clientAuthService.requestPasswordResetOtp(request));
    }

    @PostMapping("/password/verify-reset-otp")
    public ResponseEntity<?> verifyPasswordResetOtp(@RequestBody PasswordResetOtpVerifyRequest request) {
        return ResponseEntity.ok(clientAuthService.verifyPasswordResetOtp(request));
    }

    @PostMapping("/password/verify-security-answers")
    public ResponseEntity<?> verifySecurityAnswers(@RequestBody SecurityChallengeRequest request) {
        return ResponseEntity.ok(clientAuthService.verifySecurityAnswers(request));
    }

    @PostMapping("/password/reset-with-token")
    public ResponseEntity<?> resetPasswordWithToken(@RequestBody NewPasswordRequest request) {
        return ResponseEntity.ok(clientAuthService.resetPasswordWithToken(request));
    }
}