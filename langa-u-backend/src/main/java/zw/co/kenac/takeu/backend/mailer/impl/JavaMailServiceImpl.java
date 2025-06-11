package zw.co.kenac.takeu.backend.mailer.impl;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.mailer.dto.EmailGenericDto;
import zw.co.kenac.takeu.backend.mailer.templates.MailTemplates;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;

import java.util.Optional;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class JavaMailServiceImpl implements JavaMailService {

    private final JavaMailSender mailSender;
    private final DeliveryRepository deliveryRepository;

    @Async
    @Override
    public void sendGenericEmail(EmailGenericDto emailGenericDto) {
        try {

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            

            if (emailGenericDto.recipient() == null || emailGenericDto.recipient().isEmpty()) {
                log.error("========> Failed to send email: recipient is null or empty");
                return;
            }
            
            helper.setTo(emailGenericDto.recipient());
            helper.setFrom("apps@kenac.co.zw");
            helper.setSubject(emailGenericDto.subject());
            

            if (emailGenericDto.cc() != null && !emailGenericDto.cc().isEmpty()) {
                helper.setCc(emailGenericDto.cc());
            }
            boolean isHtml = emailGenericDto.body().contains("<html>") || 
                           emailGenericDto.body().contains("<body>") || 
                           emailGenericDto.body().contains("<div>");
            helper.setText(emailGenericDto.body(), isHtml);
            mailSender.send(message);
            log.info("========> Email sent successfully to: {}", emailGenericDto.recipient());
        } catch (MessagingException e) {
            log.error("=======> Failed to send email: {}", e.getMessage());
        }
    }

    @Async
    @Override
    public void sendOtpVerification(String email, String name, String otp) {
        if (email == null) {
            log.error("========> Failed to send OTP verification: email is null");
            return;
        }

        String htmlTemplate = MailTemplates.generateOtpVerificationTemplate(name, otp);
        EmailGenericDto emailDto = EmailGenericDto.builder()
                .recipient(email)
                .subject("OTP Verification Code")
                .body(htmlTemplate)
                .build();
                
        sendGenericEmail(emailDto);
        log.info("==========> OTP verification requested for: {}", email);
    }

    @Async
    @Override
    public void sendAccountCreationInfo(String name, String email, String mobile, String password) {
        if (email == null) {
            log.error("========> Failed to send account creation info: email is null");
            return;
        }

        String messageText = MailTemplates.generateAccountCreationTemplate(name, email, mobile, password);
        EmailGenericDto emailDto = EmailGenericDto.builder()
                .recipient(email)
                .subject("Account Creation Information")
                .body(messageText)
                .build();
                
        sendGenericEmail(emailDto);
        log.info("===========> Account information sent to: {}", email);
    }

    @Async
    @Override
    public void sendDeliveryCompletionOtp(Long deliveryId) {
        Optional<DeliveryEntity> deliveryEntityOptional = deliveryRepository.findById(deliveryId);
        if (deliveryEntityOptional.isPresent()) {
            DeliveryEntity deliveryEntity = deliveryEntityOptional.get();
            String otp = deliveryEntity.getCompletionOtp();
            String email = deliveryEntity.getCustomer().getEmailAddress();
            String name = deliveryEntity.getCustomer().getFullName() + " " + deliveryEntity.getCustomer().getLastname();
            
            if (email == null || email.isEmpty()) {
                log.error("==========> Failed to send delivery completion OTP: customer email is null");
                return;
            }
            String htmlTemplate = MailTemplates.generateDeliveryCompletionOtpTemplate(name, otp, deliveryEntity);
            EmailGenericDto emailDto = EmailGenericDto.builder()
                    .recipient(email)
                    .subject("Delivery Completion OTP")
                    .body(htmlTemplate)
                    .build();
                    
            sendGenericEmail(emailDto);
            log.info("==========> Delivery completion OTP sent to customer: {}", email);
        } else {
            log.error("=============> Could not find delivery with ID: {}", deliveryId);
        }
    }
    
    @Async
    @Override
    public void sendPasswordResetEmail(String email, String name, String resetToken, String resetLink) {
        if (email == null || email.isEmpty()) {
            log.error("========> Failed to send password reset email: email is null or empty");
            return;
        }
        
        String htmlTemplate = MailTemplates.generatePasswordResetTemplate(name, resetToken, resetLink);
        EmailGenericDto emailDto = EmailGenericDto.builder()
                .recipient(email)
                .subject("Password Reset Request")
                .body(htmlTemplate)
                .build();
                
        sendGenericEmail(emailDto);
        log.info("==========> Password reset email sent to: {}", email);
    }
    @Async
    @Override
    public void sendDeliveryCompletionEmail(Long deliveryId) {
        Optional<DeliveryEntity> deliveryEntityOptional = deliveryRepository.findById(deliveryId);
        if (deliveryEntityOptional.isPresent()) {
            DeliveryEntity deliveryEntity = deliveryEntityOptional.get();
            String email = deliveryEntity.getCustomer().getEmailAddress();
            String name = deliveryEntity.getCustomer().getFullName() + " " + deliveryEntity.getCustomer().getLastname();

            if (email == null || email.isEmpty()) {
                log.error("==========> Failed to send delivery completion email: customer email is null");
                return;
            }

            String htmlTemplate = MailTemplates.generateDeliveryCompletionTemplate(name, deliveryEntity);
            EmailGenericDto emailDto = EmailGenericDto.builder()
                    .recipient(email)
                    .subject("Delivery Completed - Take U Service")
                    .body(htmlTemplate)
                    .build();

            sendGenericEmail(emailDto);
            log.info("==========> Delivery completion email sent to customer: {}", email);
        } else {
            log.error("=============> Could not find delivery with ID: {}", deliveryId);
        }
    }
}
