package zw.co.kenac.takeu.backend.walletmodule.models;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Date;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/24/2025
 */

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
public class WalletBalance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private WalletAccount wallet;

    @Column(precision = 30, scale = 2)
    private BigDecimal  amount;
    @Column(precision = 30, scale = 2)
    private BigDecimal runningBalance; // Added to track balance after each transaction

    @Column(length = 100)
    private String transactionRef;
    @Enumerated(EnumType.STRING)
    private WalletBalanceType balanceType;

    @ManyToOne
    @JoinColumn(name = "currency_id")
    private Currencies currency;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sub_transaction_id", referencedColumnName = "id")
    private SubTransaction transaction;

    @CreationTimestamp
    private LocalDateTime dateCreated;
}
