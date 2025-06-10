package zw.co.kenac.takeu.backend.service.driver.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordLinkRequest;
import zw.co.kenac.takeu.backend.dto.auth.PasswordResetRequest;
import zw.co.kenac.takeu.backend.dto.auth.VerifyAccountRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverLoginResponse;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverProfileResponse;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterRequest;
import zw.co.kenac.takeu.backend.dto.auth.driver.DriverRegisterResponse;
import zw.co.kenac.takeu.backend.exception.custom.FileRequiredException;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.exception.custom.UrlAuthorizationException;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.OtpVerification;
import zw.co.kenac.takeu.backend.model.PasswordResetToken;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.repository.OtpVerificationRepository;
import zw.co.kenac.takeu.backend.repository.PasswordResetTokenRepository;
import zw.co.kenac.takeu.backend.repository.UserRepository;
import zw.co.kenac.takeu.backend.security.UserPrincipal;
import zw.co.kenac.takeu.backend.security.provider.JwtTokenProvider;
import zw.co.kenac.takeu.backend.service.driver.DriverAuthService;
import zw.co.kenac.takeu.backend.service.internal.DocumentService;
import zw.co.kenac.takeu.backend.service.internal.DriverRatingService;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.SecureRandom;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.USER_MISSING;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class DriverAuthServiceImpl implements DriverAuthService {

    private final UserRepository userRepository;
    private final DriverRepository driverRepository;
    private final AuthenticationManager authManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;
    private final OtpVerificationRepository verificationRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final JavaMailService mailService;
    private final WalletAccountService walletAccountService;
    @Autowired
    private DriverRatingService driverRatingService;

    private record DocumentUpload(String bucketType, MultipartFile file, String fieldName,
                                  java.util.function.Consumer<String> entitySetter) {}


    @Autowired
    private DocumentService documentService;

    @Value("${app.frontend-url:http://localhost:3000}")
    private String frontendUrl;

    @Override
    public DriverLoginResponse login(LoginRequest loginRequest) {
        UserEntity loginUser = userRepository.findByEmailAddressOrMobileNumberAndRole(loginRequest.loginId(), "DRIVER")
                .orElseThrow(() -> new ResourceNotFoundException(USER_MISSING));

        if (!Objects.equals(loginUser.getUserType(), "DRIVER"))
            throw new UrlAuthorizationException("You are not allowed to login. Please register a DRIVER account.");

        authenticate(loginRequest.loginId(), loginRequest.password());

        UserPrincipal userPrincipal = new UserPrincipal(loginUser);

        String accessToken = getAccessToken(userPrincipal);
        String refreshToken = getRefreshToken(userPrincipal);
        log.info("=======> this is the driver driverId {}",loginUser.getDriver().getEntityId());
        WalletAccount walletAccount = walletAccountService.findWalletAccountByDriverId(loginUser.getDriver().getEntityId());

        return new DriverLoginResponse(
                accessToken,
                refreshToken,
                "DRIVER",
                loginUser.getEntityId(),
                new DriverProfileResponse(
                        loginUser.getDriver().getEntityId(),
                        loginUser.getEmailAddress(),
                        loginUser.getMobileNumber(),
                        loginUser.getFirstname(),
                        loginUser.getLastname(),
                        loginUser.getDriver().getGender(),
                        loginUser.getDriver().getAddress(),
                        loginUser.getDriver().getProfilePhotoUrl(),
                        loginUser.getDriver().getNationalIdImage(),
                        BigDecimal.ZERO,
                        driverRatingService.calculateAverageRating(loginUser.getDriver().getEntityId()).doubleValue(),
                        walletAccount != null ? walletAccount.getId() : null,
                        loginUser.getDriver().getOnlineStatus(),
                        loginUser.getDriver().getSearchRadiusInKm()
                )
        );
    }

    @Override
    public DriverRegisterResponse register(DriverRegisterRequest registerRequest) throws IOException {
        UserEntity userEntity = new UserEntity();
        userEntity.setFirstname(registerRequest.firstname());
        userEntity.setLastname(registerRequest.lastname());
        userEntity.setDateJoined(LocalDateTime.now());
        userEntity.setMiddleName(registerRequest.middleName());
        userEntity.setEmailAddress(registerRequest.email());
        userEntity.setMobileNumber(registerRequest.phoneNumber());
        userEntity.setUserPassword(passwordEncoder.encode(registerRequest.password()));

        userEntity.setUserType("DRIVER");

        userEntity.setAccountNonExpired(true);
        userEntity.setAccountNonLocked(true);
        userEntity.setCredentialsNonExpired(true);
        userEntity.setEnabled(false);

        UserEntity user = userRepository.save(userEntity);

        DriverEntity driverEntity = new DriverEntity();
        driverEntity.setUserEntity(user);
        driverEntity.setEmail(registerRequest.email());
        driverEntity.setFirstname(registerRequest.firstname());
        driverEntity.setLastname(registerRequest.lastname());
        driverEntity.setMobileNumber(registerRequest.phoneNumber());
        driverEntity.setApprovalStatus("PENDING");
        driverEntity.setGender(registerRequest.gender());
        driverEntity.setAddress(registerRequest.address());
        driverEntity.setIsBusy(false);
        driverEntity.setIsOnline(false);
        driverEntity.setNationalIdNo(registerRequest.nationalIdNumber());
        driverEntity.setDriverLicenseNo("");

        List<DocumentUpload> requiredDocuments = List.of(
                new DocumentUpload(
                        "drivers-license-images",
                        registerRequest.driversLicenseImage(),
                        "Drivers licence image",
                        driverEntity::setDriversLicenseUrl
                ),
                new DocumentUpload(
                        "national-id-images",
                        registerRequest.nationalIdImage(),
                        "National ID image",
                        driverEntity::setNationalIdImage
                ),
                new DocumentUpload(
                        "profile-photos",
                        registerRequest.profilePhoto(),
                        "Profile photo image",
                        driverEntity::setProfilePhotoUrl
                )
        );


        for (DocumentUpload doc : requiredDocuments) {
            if (doc.file() == null) {
                throw new FileRequiredException(doc.fieldName() + " is required.");
            }

            try {
                String fileUrl = documentService.uploadDocument(doc.bucketType(), doc.file());
                doc.entitySetter().accept(fileUrl);
            } catch (Exception e) {
                throw new RuntimeException("Failed to upload " + doc.fieldName() + ": " + e.getMessage(), e);
            }
        }

        driverRepository.save(driverEntity);

        generateOtp(user);

        return new DriverRegisterResponse(user.getEntityId(), user.getEmailAddress(), user.getMobileNumber());
    }

    @Override
    public String verifyAccount(VerifyAccountRequest request) {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.loginID(), "DRIVER")
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
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.loginId(), "DRIVER")
                .orElseThrow(() -> new ResourceNotFoundException("User not found with login ID: " + request.loginId()));

        // Check if user is enabled
        if (!user.isEnabled()) {
            throw new RuntimeException("Your account is not verified. Please verify your account first.");
        }

        // Invalidate any existing tokens for this user
        passwordResetTokenRepository.findByUserAndUsedFalse(user)
            .ifPresent(token -> {
                token.setUsed(true);
                passwordResetTokenRepository.save(token);
            });

        // Generate a new token
        String resetCode = generateOtp();

        // Create a token entity
        PasswordResetToken passwordResetToken = new PasswordResetToken();
        passwordResetToken.setToken(resetCode);
        passwordResetToken.setUser(user);
        // Set expiry for 1 hour from now
        passwordResetToken.setExpiryDate(LocalDateTime.now().plusHours(1));
        passwordResetToken.setUsed(false);

        passwordResetTokenRepository.save(passwordResetToken);

        // Generate reset link
        String resetLink = frontendUrl + "/reset-password?token=" + resetCode;

        // Send password reset email
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

    private String saveFileToDirectory(MultipartFile file, String directory) throws IOException {
        String UPLOAD_DIR = System.getProperty("user.home") + "/Code/Uploads/" + directory;
        File uploadDir = new File(UPLOAD_DIR);

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());

        if (originalFilename.isEmpty()) {
            return "";
        }

        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmssSSSSSSSSS").format(new Date());

        originalFilename = originalFilename.replaceAll("\\s+", "");

        String nameWithoutExt = originalFilename.contains(".") ?
                originalFilename.substring(0, originalFilename.lastIndexOf(".")) :
                originalFilename;
        String extension = originalFilename.contains(".") ?
                originalFilename.substring(originalFilename.lastIndexOf(".")) : "";

        String newFilename = nameWithoutExt + "_" + timestamp + extension;

        Path filePath = Paths.get(UPLOAD_DIR, newFilename).toAbsolutePath().normalize();

        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return filePath.toString();
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

    private String generateResetToken() {
        return UUID.randomUUID().toString();
    }
}
