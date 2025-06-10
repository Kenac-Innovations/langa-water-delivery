package zw.co.kenac.takeu.backend.sms.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.sms.SmsService;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
@Service
@RequiredArgsConstructor
public class SmsServiceImpl implements SmsService {

    @Override
    public void sendVerificationOption(String phoneNumber, String verificationCode) {
        return;
    }
}
