package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.auth.*;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverLoginResponse;

import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.exception.custom.UrlAuthorizationException;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.repository.UserRepository;
import zw.co.kenac.takeu.backend.security.UserPrincipal;
import zw.co.kenac.takeu.backend.security.provider.JwtTokenProvider;
import zw.co.kenac.takeu.backend.service.internal.AuthService;

import java.math.BigDecimal;
import java.util.Objects;

import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.USER_MISSING;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final AuthenticationManager authManager;
    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public LoginResponse login(LoginRequest loginRequest) {
        UserEntity loginUser = userRepository.findByEmailAddressOrMobileNumber(loginRequest.loginId())
                .orElseThrow(() -> new ResourceNotFoundException(USER_MISSING));

        authenticate(loginRequest.loginId(), loginRequest.password());

        UserPrincipal userPrincipal = new UserPrincipal(loginUser);

        String accessToken = getAccessToken(userPrincipal);
        String refreshToken = getRefreshToken(userPrincipal);

        return new LoginResponse(
                accessToken,
                refreshToken,
                loginUser.getUserType(),
                loginUser.getEntityId(),
                loginUser.getFirstname(),
                loginUser.getLastname(),
                loginUser.getEmailAddress(),
                loginUser.getMobileNumber()
        );
    }

    @Override
    public String verifyAccount(VerifyAccountRequest request) {
        return "";
    }

    @Override
    public String requestPasswordLink(PasswordLinkRequest request) {
        return "";
    }

    @Override
    public String resetPassword(PasswordResetRequest request) {
        return "";
    }

    private void authenticate(String username, String password) {
        authManager.authenticate(new UsernamePasswordAuthenticationToken(username, password));
    }

    private String getAccessToken(UserPrincipal user) {
        return jwtTokenProvider.generateJwtToken(user);
    }

    private String getRefreshToken(UserPrincipal user) {
        return jwtTokenProvider.generateJwtRefreshToken(user);
    }
}
