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
import zw.co.kenac.takeu.backend.dto.auth.client.*;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.exception.custom.UrlAuthorizationException;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.model.*;
import zw.co.kenac.takeu.backend.repository.*;
import zw.co.kenac.takeu.backend.security.UserPrincipal;
import zw.co.kenac.takeu.backend.security.provider.JwtTokenProvider;
import zw.co.kenac.takeu.backend.service.client.ClientAuthService;
import zw.co.kenac.takeu.backend.repository.ClientSecurityAnswerRepository;
import zw.co.kenac.takeu.backend.repository.SecurityQuestionsRepository;
import zw.co.kenac.takeu.backend.model.ClientSecurityAnswerEntity;
import zw.co.kenac.takeu.backend.model.SecurityQuestionsEntity;
import zw.co.kenac.takeu.backend.sms.SmsService;
import zw.co.kenac.takeu.backend.mailer.dto.EmailGenericDto;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Random;
import java.util.stream.Collectors;
import java.util.UUID;

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
    private final OtpVerificationRepository otpVerificationRepository;
    private final ClientSecurityAnswerRepository clientSecurityAnswerRepository;
    private final SecurityQuestionsRepository securityQuestionsRepository;
    private final SmsService smsService;

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
        client.setFullName(request.firstname());
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
    public ClientLoginResponse registerClient(ClientRegisterRequestDto requestDto) {
        UserEntity userEntity = new UserEntity();

        userEntity.setFirstname(requestDto.getFullName());
        userEntity.setLastname(requestDto.getFullName());
        userEntity.setEmailAddress(requestDto.getEmail());
        userEntity.setMobileNumber(requestDto.getPhoneNumber());
        userEntity.setUserPassword(passwordEncoder.encode(requestDto.getPassword()));

//        UserTypeEntity userType = userTypeRepository.findUserTypeByTypeName("CLIENT")
//                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        userEntity.setUserType("CLIENT");

        userEntity.setAccountNonExpired(true);
        userEntity.setAccountNonLocked(true);
        userEntity.setCredentialsNonExpired(true);
        userEntity.setEnabled(true);


        UserEntity user = userRepository.save(userEntity);

        ClientEntity client = new ClientEntity();
        client.setFullName(requestDto.getFullName ());
        client.setLastname(requestDto.getFullName());
        client.setEmailAddress(requestDto.getEmail());

        client.setMobileNumber(requestDto.getPhoneNumber());
        client.setCommunicationChannels(requestDto.getCommChannels());

        ClientAddressesEntity clientAddresses = ClientAddressesEntity.builder()
                .addressEntered(requestDto.getAddress().getAddressEntered())
                .addressFormatted(requestDto.getAddress().getAddressFormatted())
                .latitude(requestDto.getAddress().getLatitude())
                .longitude(requestDto.getAddress().getLongitude())
                .title("Home Address")
                .build();


        List<ClientAddressesEntity> addresses = new ArrayList<>();
        addresses.add(clientAddresses);
        client.setClientAddresses(addresses);

        client.setUserEntity(userEntity);
        ClientEntity clientEntity = clientRepository.save(client);
        user.setCustomer(clientEntity);

        // Save security answers
        if (requestDto.getSecurityAnswers() != null && !requestDto.getSecurityAnswers().isEmpty()) {
            List<ClientSecurityAnswerEntity> securityAnswers = requestDto.getSecurityAnswers().stream()
                    .map(answerDto -> {
                        SecurityQuestionsEntity question = securityQuestionsRepository.findById(answerDto.getQuestionId())
                                .orElseThrow(() -> new ResourceNotFoundException("Security question not found with id: " + answerDto.getQuestionId()));
                        
                        return ClientSecurityAnswerEntity.builder()
                                .client(clientEntity)
                                .securityQuestion(question)
                                .answer(answerDto.getAnswer())
                                .build();
                    })
                    .collect(Collectors.toList());
            
            clientSecurityAnswerRepository.saveAll(securityAnswers);
        }

        UserPrincipal userPrincipal = new UserPrincipal(user);
        String accessToken = getAccessToken(userPrincipal);
        String refreshToken = getRefreshToken(userPrincipal);

        return new ClientLoginResponse(
                accessToken,
                refreshToken,
                user.getUserType(),
                user.getEntityId(),
                new ClientProfileResponse(
                        user.getEntityId(),
                        user.getCustomer().getEmailAddress(),
                        user.getCustomer().getMobileNumber(),
                        user.getFirstname(),
                        user.getLastname(),
                        BigDecimal.ZERO
                )
        );
    }

    @Override
    public Boolean verifyAccountOtp(OtpVerificationDto otpVerificationDto) {
        if (otpVerificationDto.getOtp() == null || otpVerificationDto.getOtp().isBlank()) {
            throw new IllegalArgumentException("OTP is required");
        }
        OtpVerification otpVerification = otpVerificationRepository.findByOtpAndLoginId(otpVerificationDto.getPhoneOrEmail(),otpVerificationDto.getOtp()).orElseThrow(() -> new ResourceNotFoundException("Invalid OTP"));
        if(otpVerification.getVerified()!=null && otpVerification.getVerified()){
            throw new RuntimeException("Otp already used.");
        }
        if(otpVerification.getExpired()!=null && otpVerification.getExpired() || otpVerification.getExpiryDate().isBefore(LocalDateTime.now())){
            throw new RuntimeException("Otp expired.");
        }
        otpVerification.setVerified(true);
        otpVerification.setExpired(true);
        otpVerificationRepository.save(otpVerification);
        return true;
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
        return null;
    }

    @Override
    public String requestPasswordResetOtp(PasswordResetOtpRequest request) {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.getEmail(), "CLIENT")
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + request.getEmail()));

        String otp = new Random().ints(100000, 999999)
                .findFirst()
                .getAsInt() + "";

        OtpVerification otpVerification = otpVerificationRepository.findByUser(user).orElse(new OtpVerification());
        otpVerification.setOtp(otp);
        otpVerification.setUser(user);
        otpVerification.setExpiryDate(LocalDateTime.now().plusMinutes(15));
        otpVerification.setVerified(false);
        otpVerificationRepository.save(otpVerification);

        // Assuming a mail service exists to send the OTP
        mailService.sendPasswordResetEmail(user.getEmailAddress(), user.getFirstname(), otp,"");

        return "An OTP has been sent to your email address.";
    }

    @Override
    public List<SecurityQuestionDto> verifyPasswordResetOtp(PasswordResetOtpVerifyRequest request) {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.getEmail(), "CLIENT")
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + request.getEmail()));

        OtpVerification otpVerification = otpVerificationRepository.findByUserAndOtp(user, request.getOtp())
                .orElseThrow(() -> new ResourceNotFoundException("Invalid or expired OTP."));

        if (otpVerification.getExpiryDate().isBefore(LocalDateTime.now())) {
            otpVerification.setExpired(true);
            otpVerificationRepository.save(otpVerification);
            throw new RuntimeException("OTP has expired. Please request a new one.");
        }

        if (otpVerification.getVerified()) {
            throw new RuntimeException("This OTP has already been used.");
        }

        otpVerification.setVerified(true);
        otpVerificationRepository.save(otpVerification);

        // Fetch 2 random security questions for the user
        List<ClientSecurityAnswerEntity> clientAnswers = clientSecurityAnswerRepository.findByClient(user.getCustomer());
        if (clientAnswers == null || clientAnswers.size() < 2) {
            throw new RuntimeException("Not enough security questions configured for this account.");
        }

        Collections.shuffle(clientAnswers);

        return clientAnswers.stream()
                .limit(2)
                .map(answer -> new SecurityQuestionDto(answer.getSecurityQuestion().getEntityId(), answer.getSecurityQuestion().getQuestion()))
                .collect(Collectors.toList());
    }

    @Override
    public String verifySecurityAnswers(SecurityChallengeRequest request) {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumberAndRole(request.getEmail(), "CLIENT")
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + request.getEmail()));

        if (request.getAnswers() == null || request.getAnswers().size() < 2) {
            throw new IllegalArgumentException("Two security answers are required.");
        }

        List<ClientSecurityAnswerEntity> storedAnswers = clientSecurityAnswerRepository.findByClient(user.getCustomer());
        if (storedAnswers == null || storedAnswers.isEmpty()) {
            throw new RuntimeException("No security questions found for this user.");
        }

        long correctAnswers = request.getAnswers().stream()
                .filter(submittedAnswer -> storedAnswers.stream()
                        .anyMatch(storedAnswer ->
                                storedAnswer.getSecurityQuestion().getEntityId().equals(submittedAnswer.getQuestionId()) &&
                                        passwordEncoder.matches(
                                                submittedAnswer.getAnswer().trim().toLowerCase(),
                                                storedAnswer.getAnswer()
                                        )
                        )
                ).count();

        if (correctAnswers != request.getAnswers().size()) {
            throw new RuntimeException("One or more security answers are incorrect.");
        }
        
        // Invalidate any existing tokens for this user
        passwordResetTokenRepository.findByUserAndUsedFalse(user).ifPresent(token -> {
            token.setUsed(true);
            passwordResetTokenRepository.save(token);
        });

        // Generate a new single-use token for the final password reset step
        String token = UUID.randomUUID().toString();
        PasswordResetToken passwordResetToken = new PasswordResetToken();
        passwordResetToken.setToken(token);
        passwordResetToken.setUser(user);
        passwordResetToken.setExpiryDate(LocalDateTime.now().plusMinutes(10)); // Token valid for 10 minutes
        passwordResetTokenRepository.save(passwordResetToken);

        return token;
    }

    @Override
    public String resetPasswordWithToken(NewPasswordRequest request) {
        PasswordResetToken passwordResetToken = passwordResetTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new ResourceNotFoundException("Invalid or expired password reset token."));

        if (!passwordResetToken.isValid()) {
            throw new RuntimeException("Token has expired or has already been used.");
        }

        UserEntity user = passwordResetToken.getUser();
        user.setUserPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordChangedAt(LocalDateTime.now());
        userRepository.save(user);

        passwordResetToken.setUsed(true);
        passwordResetTokenRepository.save(passwordResetToken);
        
        // Send confirmation email
      //  mailService.sendPasswordResetEmail(user.getEmailAddress(), user.getFirstname(), resetCode, "");

        return "Password has been reset successfully.";
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

    @Override
    public void requestOtp(OtpRequest otpRequest) {
        if (userRepository.findByEmailAddressOrMobileNumberAndRole(otpRequest.getPhoneNumber(), "CLIENT").isPresent() && userRepository.findByEmailAddressOrMobileNumberAndRole(otpRequest.getPhoneNumber(), "CLIENT").get().isEnabled()) {
            throw new RuntimeException("User with this phone number already exists.");
        }



        String otp = new Random().ints(100000, 999999)
                .findFirst()
                .getAsInt() + "";

        OtpVerification otpVerification = new OtpVerification();
        otpVerification.setOtp(otp);
        otpVerification.setVerified(false);
        otpVerification.setExpired(false);
        otpVerification.setUser(null);
        otpVerification.setEmail(otpRequest.getEmail());
        otpVerification.setPhoneNumber(otpRequest.getPhoneNumber());
        otpVerification.setExpiryDate(LocalDateTime.now().plusMinutes(30));

        otpVerificationRepository.save(otpVerification);
        mailService.sendOtpVerification(otpVerification.getEmail(), otpRequest.getFullName(), otp);
        //smsService.sendSms(otpRequest.getPhoneNumber(), "Your OTP for TakeU registration is: " + otp);
    }
}
