package zw.co.kenac.takeu.backend.controller.internal;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;

@RequestMapping("${custom.base.path}/auth")
public interface AuthController {

    @PostMapping("/login")
    ResponseEntity<GenericResponse<LoginResponse>> login(@RequestBody LoginRequest loginRequest);

    @PostMapping("/verify-account")
    void verifyAccount(@RequestBody VerifyAccountRequest verifyEmail);

    @PostMapping("/logout")
    void logout();

    @GetMapping("/request-password-link")
    void requestPasswordLink();

    @PutMapping("/reset-password")
    void resetPassword();

}
