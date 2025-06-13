package zw.co.kenac.takeu.backend.controller.customer;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.*;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterResponse;

@Tag(name = "Customer Authentication", description = "Customer authentication services for the client application")
@RequestMapping("${custom.base.path}/client/auth")
public interface ClientAuthController {

    @PostMapping("/login")
    ResponseEntity<GenericResponse<ClientLoginResponse>> login(@RequestBody LoginRequest loginRequest);

    @PostMapping("/register")
    ResponseEntity<GenericResponse<ClientRegisterResponse>> register(@RequestBody ClientRegisterRequest registerRequest);

    @PostMapping("/verify-account")
    ResponseEntity<GenericResponse<String>> verifyAccount(@RequestBody VerifyAccountRequest request);

    @PostMapping("/forgot-password")
    ResponseEntity<GenericResponse<String>> requestPasswordLink(@RequestBody PasswordLinkRequest request);


    @PutMapping("/reset-password")
    ResponseEntity<GenericResponse<String>> resetPassword(@RequestBody PasswordResetRequest request);


    @GetMapping("/validate-reset-token")
    ResponseEntity<GenericResponse<String>> validateResetToken(@RequestParam String token);

}
