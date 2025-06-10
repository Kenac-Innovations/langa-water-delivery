package zw.co.kenac.takeu.backend.walletmodule.models;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Enumerated(EnumType.STRING)
    private TransactionType type; // PAYMENT, TRANSFER, COMMISSION, WITHDRAWAL, DEPOSIT

    @Enumerated(EnumType.STRING)
    private TransactionStatus status;

    @ManyToOne
    @JoinColumn(name = "currency_id")
    private Currencies currencies;
    @Column(precision = 30,scale = 2)
    private BigDecimal principalAmount;
    @OneToOne
    @JoinColumn(name = "delivery_id")
    @JsonManagedReference
    private DeliveryEntity delivery;
    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;
    @Column(precision = 30,scale = 2)
    private BigDecimal commissionAmount;
    private String pollUrl;
    private String merchantTxnReference;

    @ManyToOne
    @JoinColumn(name = "source_wallet_id")
    private WalletAccount sourceWallet;

    @ManyToOne
    @JoinColumn(name = "destination_wallet_id")
    private WalletAccount destinationWallet;

    @ManyToOne
    @JoinColumn(name = "commission_wallet_id")
    private WalletAccount commissionWallet; // TakeU Charge Suspense Account

    private String reference;

    private String narration;

    @Column(nullable = false)
    private Long clientId; // todo to be linked to actual entity the customer entity

    private Long driverId; //  todo to be linked to actual entity the driver entity

    private Long organizationId; // Organization if applicable

    @Column
    @CreationTimestamp
    private LocalDateTime dateCreated;

    @Column
    @UpdateTimestamp
    private LocalDateTime lastUpdated;
}
