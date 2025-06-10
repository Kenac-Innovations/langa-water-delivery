package zw.co.kenac.takeu.backend.mailer;

import zw.co.kenac.takeu.backend.mailer.dto.EmailGenericDto;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
public interface JavaMailService {

    void sendOtpVerification(String email, String name, String otp);

    void sendAccountCreationInfo(String email, String mobile, String name, String password);
    void sendDeliveryCompletionOtp(Long deliveryId);

    void sendGenericEmail(EmailGenericDto emailGenericDto);
    void sendDeliveryCompletionEmail(Long deliveryId);
    void sendPasswordResetEmail(String email, String name, String resetToken, String resetLink);
}
