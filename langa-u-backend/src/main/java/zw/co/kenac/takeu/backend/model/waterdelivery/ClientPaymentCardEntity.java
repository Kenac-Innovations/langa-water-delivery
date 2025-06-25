package zw.co.kenac.takeu.backend.model.waterdelivery;

/**
 * @author Joy Pedze
 * Date: 25 Jun 2025
 * Project: langa-u-backend
 * Package: zw.co.kenac.takeu.backend.model.waterdelivery
 */

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Table(name = "ms_client_payment_card")
public class ClientPaymentCardEntity extends AbstractEntity {

    private String cardHolderName;
    private String cardNumber; // Masked or encrypted if needed
    private String expiryDate; // MM/YY
    private String cardType; // Visa, Mastercard, etc.
    private Boolean isDefault;

    @ManyToOne
    @JoinColumn(name = "client_id", referencedColumnName = "entity_id")
    private ClientEntity client;

    @CreationTimestamp
    private LocalDateTime createdDate;

    @UpdateTimestamp
    private LocalDateTime updatedDate;
}
