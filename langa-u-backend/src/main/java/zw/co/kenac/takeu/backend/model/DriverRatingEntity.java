package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.math.BigDecimal;
import java.util.Set;

@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sp_driver_rating")
public class DriverRatingEntity extends AbstractEntity {

    @Column(precision = 10, scale = 2)
    private BigDecimal rating;

    @ElementCollection
    @CollectionTable(name = "driver_rating_comments", joinColumns = @JoinColumn(name = "driver_rating_id"))
    @Column(columnDefinition = "TEXT")
    private Set<String> comments;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id")
    private DriverEntity driver;


    @OneToOne
    @JoinColumn(name = "delivery_id", referencedColumnName = "entity_id")
    private DeliveryEntity delivery;
}
