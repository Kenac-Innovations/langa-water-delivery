package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.Data;
import java.util.List;

@Data
public class PaynowPaymentRequest {
    private String reference;
    private List<PaymentItem> items;
    private String resultUrl;
    private String returnUrl;
} 