package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "ms_errands")
public class ErrandEntity extends AbstractEntity {

    @Column(precision = 38, scale = 2)
    private BigDecimal totalAmount;

    @OneToMany(mappedBy = "errand")
    private List<ErrandItemEntity> errandItems;

    @ManyToOne
    @JoinColumn(name = "client_id", referencedColumnName = "entity_id")
    private ClientEntity customer;


    @ManyToOne
    @JoinColumn(name = "driver_id", referencedColumnName = "entity_id")
    private DriverEntity driver;
}
