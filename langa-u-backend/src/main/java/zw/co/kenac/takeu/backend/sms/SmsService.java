package zw.co.kenac.takeu.backend.sms;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
public interface SmsService {

    void sendVerificationOption(String phoneNumber, String verificationCode);

}
