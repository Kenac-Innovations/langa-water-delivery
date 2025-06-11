package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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
@Table(name = "sp_drop_offs")
public class DropOffEntity extends AbstractEntity {

    @Column(length = 6)
    private String otp;

    private Double latitude;
    private Double longitude;
    private String status;
    private LocalDateTime timestamp;

    @OneToOne
    @JoinColumn(name = "delivery_id", referencedColumnName = "entity_id")
    private DeliveryEntity delivery;
}
