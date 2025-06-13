package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.math.BigDecimal;

@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "ms_wallet")
public class WalletEntity extends AbstractEntity {

    @Column(precision = 30, scale = 2)
    private BigDecimal balance;

    @Column(precision = 30, scale = 2)
    private BigDecimal credit;

    @Column(precision = 30, scale = 2)
    private BigDecimal debit;

    @ManyToOne
    private CurrencyEntity currency;

    @ManyToOne
    @JoinColumn(name = "user_entity_id", referencedColumnName = "entity_id")
    private UserEntity userEntity;

}
