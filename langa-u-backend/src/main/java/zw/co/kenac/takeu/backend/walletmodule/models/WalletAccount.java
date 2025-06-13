package zw.co.kenac.takeu.backend.walletmodule.models;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletCurrency;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;

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

public class  WalletAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String accountNumber;

    @Enumerated(EnumType.STRING)
    private WalletOwnerType ownerType; // DRIVER, ORGANIZATION, TAKEU_SYSTEM

    //private Long ownerId; // Todo this has to be a one to one relations Foreign key to either Driver or
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id")
    private DriverEntity driver;
    @Enumerated(EnumType.STRING)
    private WalletAccountStatus status;

    @Enumerated(EnumType.STRING)
    private WalletAccountType type; // E_MONEY, CASH, MAIN_SUSPENSE, CHARGE_SUSPENSE


    private Long organizationId; // For organizational drivers

    @Column
    @CreationTimestamp
    private LocalDateTime dateCreated;

    @Column
    @UpdateTimestamp
    private LocalDateTime lastUpdated;
}
