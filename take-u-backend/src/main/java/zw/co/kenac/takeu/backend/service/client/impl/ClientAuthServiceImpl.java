package zw.co.kenac.takeu.backend.service.client.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordLinkRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordResetRequest;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientProfileResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.exception.custom.UrlAuthorizationException;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.model.*;
import zw.co.kenac.takeu.backend.repository.*;
import zw.co.kenac.takeu.backend.security.UserPrincipal;
import zw.co.kenac.takeu.backend.security.provider.JwtTokenProvider;
import zw.co.kenac.takeu.backend.service.client.ClientAuthService;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Objects;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;
import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.USER_MISSING;

@Service
@RequiredArgsConstructor
public class ClientAuthServiceImpl implements ClientAuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authManager;
    private final ClientRepository clientRepository;
    private final UserTypeRepository userTypeRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final OtpVerificationRepository verificationRepository;
    private final JavaMailService mailService;
    private final PasswordResetTokenRepository passwordResetTokenRepository;

    @Override
    public ClientLoginResponse login(LoginRequest loginRequest) {
        UserEntity loginUser = userRepository.findByEmailAddressOrMobileNumber(loginRequest.loginId())
                .orElseThrow(() -> new ResourceNotFoundException(USER_MISSING));

        if (!Objects.equals(loginUser.getUserType(), "CLIENT"))
            throw new UrlAuthorizationException("You are not allowed to login. Please register a CUSTOMER account.");

        authenticate(loginRequest.loginId(), loginRequest.password());

        UserPrincipal userPrincipal = new UserPrincipal(loginUser);

        String accessToken = getAccessToken(userPrincipal);
        String refreshToken = getRefreshToken(userPrincipal);

        return new ClientLoginResponse(
                accessToken,
                refreshToken,
                loginUser.getUserType() != null ? loginUser.getUserType() : "CLIENT",
                loginUser.getEntityId(),
                new ClientProfileResponse(
                        loginUser.getEntityId(),
                        loginUser.getCustomer().getEmailAddress(),
                        loginUser.getCustomer().getMobileNumber(),
                        loginUser.getFirstname(),
                        loginUser.getLastname(),
                        BigDecimal.ZERO
                )
        );
    }

    @Override
    public ClientRegisterResponse register(ClientRegisterRequest request) {
        UserEntity userEntity = new UserEntity();

        userEntity.setFirstname(request.firstname());
        userEntity.setLastname(request.lastname());
        userEntity.setEmailAddress(request.email());
        userEntity.setMobileNumber(request.phoneNumber());
        userEntity.setUserPassword(passwordEncoder.encode(request.password()));

        UserTypeEntity userType = userTypeRepository.findUserTypeByTypeName("CLIENT").orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        userEntity.setUserType(userType.getTypeName().toUpperCase());

        userEntity.setAccountNonExpired(true);
        userEntity.setAccountNonLocked(true);
        userEntity.setCredentialsNonExpired(true);
        userEntity.setEnabled(false);

        UserEntity user = userRepository.save(userEntity);

        ClientEntity client = new ClientEntity();
        client.setFirstname(request.firstname());
        client.setLastname(request.lastname());
        client.setEmailAddress(request.email());
        client.setMobileNumber(request.phoneNumber());
        client.setUserEntity(userEntity);
        ClientEntity clientEntity = clientRepository.save(client);
        user.setCustomer(clientEntity);

        generateOtp(user);

        return new ClientRegisterResponse(
                user.getEntityId(),
                user.getEmailAddress(),
                user.getMobileNumber()
        );
    }

    @Override
    public String verifyAccount(VerifyAccountRequest request) {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.loginID(), "CLIENT")
                .orElseThrow(() -> new ResourceNotFoundException(USER_MISSING));

        verificationRepository.findByUserAndOtp(user, request.otp())
                .ifPresentOrElse(verification -> {
                    if (verification.getVerified()) {
                        throw new RuntimeException("Account already verified.");
                    }
                    if (LocalDateTime.now().isAfter(verification.getExpiryDate())) {
                        throw new RuntimeException("OTP expired. Please request a new OTP.");
                    }
                    verification.setVerified(true);
                    verification.setExpired(true);
                    verificationRepository.save(verification);

                    user.setEnabled(true);
                    userRepository.save(user);
                }, () -> {
                    throw new RuntimeException("Invalid OTP. Please provide a valid OTP.");
                });
        return "Congratulations, your account has been verified successfully.";
    }

    @Override
    public boolean validateResetToken(String token) {
        return passwordResetTokenRepository.findByToken(token)
                .map(PasswordResetToken::isValid)
                .orElse(false);
    }

    @Override
    public String requestPasswordLink(PasswordLinkRequest request) {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.loginId(), "CLIENT")
                .orElseThrow(() -> new ResourceNotFoundException("User not found with login ID: " + request.loginId()));

        // Check if user is enabled
        if (!user.isEnabled()) {
            throw new RuntimeException("Your account is not verified. Please verify your account first.");
        }


        passwordResetTokenRepository.findByUserAndUsedFalse(user)
                .ifPresent(token -> {
                    token.setUsed(true);
                    passwordResetTokenRepository.save(token);
                });


        String resetCode = generateOtp();


        PasswordResetToken passwordResetToken = new PasswordResetToken();
        passwordResetToken.setToken(resetCode);
        passwordResetToken.setUser(user);

        passwordResetToken.setExpiryDate(LocalDateTime.now().plusHours(1));// PANAPA WE ARE SETTING THE PASSWORD EXPIREY TIME
        passwordResetToken.setUsed(false);

        passwordResetTokenRepository.save(passwordResetToken);

        String resetLink =resetCode;

        String userName = user.getFirstname() + " " + user.getLastname();
        mailService.sendPasswordResetEmail(user.getEmailAddress(), userName, resetCode, resetLink);

        return "Password reset link has been sent to your email address. Please check your inbox.";
    }

    @Override
    public String resetPassword(PasswordResetRequest request) {
        if (request.token() == null || request.token().isBlank()) {
            throw new IllegalArgumentException("Reset token is required");
        }

        if (request.newPassword() == null || request.newPassword().isBlank()) {
            throw new IllegalArgumentException("New password is required");
        }

        // Find token in the database
        PasswordResetToken passwordResetToken = passwordResetTokenRepository.findByToken(request.token())
                .orElseThrow(() -> new ResourceNotFoundException("Invalid or expired reset token"));

        // Check if token is valid
        if (!passwordResetToken.isValid()) {
            throw new RuntimeException("Reset token has expired or already been used");
        }

        // Get user from token
        UserEntity user = passwordResetToken.getUser();

        // Update password
        user.setUserPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);

        // Mark token as used
        passwordResetToken.setUsed(true);
        passwordResetTokenRepository.save(passwordResetToken);

        return "Your password has been reset successfully. You can now login with your new password.";
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

    private String generateOtp() {
        String digits = "0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder otp = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            otp.append(digits.charAt(random.nextInt(digits.length())));
        }
        return otp.toString();
    }

    @Async
    public void generateOtp(UserEntity user) {
        OtpVerification verification = user.getVerification() != null ? user.getVerification() : new OtpVerification();

        String otp = generateOtp();

        verification.setOtp(otp);
        verification.setUser(user);

        LocalDateTime expiryDate = LocalDateTime.now().plusMinutes(15);
        verification.setExpiryDate(expiryDate);
        verification.setVerified(false);
        verification.setExpired(false);

        verificationRepository.save(verification);

        mailService.sendOtpVerification(user.getEmailAddress(), user.getFirstname() + user.getLastname(), otp);
    }
}
