package zw.co.kenac.takeu.backend.walletmodule.models;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;

import java.util.Date;

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

public class Currencies {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    private String alphaCode;
    @Column(unique = true)
    private String numericCode;
    @Enumerated(EnumType.STRING)
    private WalletAccountStatus status;
    @CreationTimestamp
    private Date dateCreated;
}
