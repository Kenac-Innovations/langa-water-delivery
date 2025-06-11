package zw.co.kenac.takeu.backend.controller.driver;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.PasswordLinkRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordResetRequest;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterResponse;

import java.io.IOException;

@Tag(name = "Driver Authentication Service")
@RequestMapping("${custom.base.path}/driver/auth")
public interface DriverAuthController {

    @PostMapping("/login")
    ResponseEntity<GenericResponse<DriverLoginResponse>> login(@RequestBody LoginRequest loginRequest);

    @PostMapping(value = "/register", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    ResponseEntity<GenericResponse<DriverRegisterResponse>> register(@ModelAttribute @Valid DriverRegisterRequest registerRequest) throws IOException;

    @PostMapping("/verify-account")
    ResponseEntity<GenericResponse<String>> verifyAccount(@RequestBody VerifyAccountRequest request);


    @PostMapping("/forgot-password")
    ResponseEntity<GenericResponse<String>> requestPasswordLink(@RequestBody PasswordLinkRequest request);


    @PutMapping("/reset-password")
    ResponseEntity<GenericResponse<String>> resetPassword(@RequestBody PasswordResetRequest request);


    @GetMapping("/validate-reset-token")
    ResponseEntity<GenericResponse<String>> validateResetToken(@RequestParam String token);

}
