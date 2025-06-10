package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.Data;
import java.util.List;

@Data
public class PaynowMobilePaymentRequest {
    private String reference;
    private List<PaymentItem> items;
    private String mobileNumber;
    private String email;
} 