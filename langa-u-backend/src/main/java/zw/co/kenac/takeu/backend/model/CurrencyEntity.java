package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.util.List;

@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "st_currency")
public class CurrencyEntity extends AbstractEntity {

    private String currency;

    private String currencyName;

    @Column(name = "active")
    private Boolean active = Boolean.TRUE;

    @OneToMany(mappedBy = "currency")
    private List<WalletEntity> wallets;
}
