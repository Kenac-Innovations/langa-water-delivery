package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.time.LocalDateTime;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 22/4/2025
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sp_pickups")
public class PickupEntity extends AbstractEntity {

    private Double latitude;

    private Double longitude;

    private LocalDateTime timestamp;

    private String pickupImage;

    @OneToOne
    @JoinColumn(name = "delivery_id", referencedColumnName = "entity_id")
    private DeliveryEntity delivery;
}
