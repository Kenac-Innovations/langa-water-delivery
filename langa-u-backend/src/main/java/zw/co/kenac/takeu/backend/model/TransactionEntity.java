package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "sp_transaction")
public class TransactionEntity extends AbstractEntity {

    @Column(precision = 30, scale = 2)
    private BigDecimal amount;

    private String reference;

    // debit or credit
    private String type;

    @ManyToOne
    @JoinColumn(name = "transaction_id", referencedColumnName = "entity_id")
    private CurrencyEntity currency;
}
