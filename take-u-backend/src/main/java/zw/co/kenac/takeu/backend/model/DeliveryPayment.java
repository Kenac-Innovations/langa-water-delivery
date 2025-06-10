package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
public class DeliveryPayment {

    @Column(length = 3)
    private String currency;

    @Column(precision = 10, scale = 4)
    private BigDecimal amount;

    private String paymentMethod;

    private String paymentStatus;

    private String paymentReference;

}
