package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sp_available_driver")
public class AvailableDriverEntity extends AbstractEntity {

    private Double latitude;

    private Double longitude;

    private LocalDateTime dateAccepted;

    // open / accepted / declined
    private String status;

    @ManyToOne
    @JoinColumn(name = "driver_id", referencedColumnName = "entity_id")
    private DriverEntity driver;

    @ManyToOne
    @JoinColumn(name = "vehicle_id", referencedColumnName = "entity_id")
    private VehicleEntity vehicle;

    @ManyToOne
    @JoinColumn(name = "delivery_id", referencedColumnName = "entity_id")
    private DeliveryEntity delivery;
}
