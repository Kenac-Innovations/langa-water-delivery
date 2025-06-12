package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;
import zw.co.kenac.takeu.backend.model.embedded.VehicleDocument;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "ms_vehicle")
public class VehicleEntity extends AbstractEntity {

    private String vehicleModel;

    private String vehicleColor;

    private String vehicleMake;

    private String licensePlateNo;

    private Boolean active;

    private String vehicleType;

    private String vehicleStatus;
    @Embedded
    private VehicleDocument vehicleDocument;
    private String approvedBy;

    private LocalDateTime approvedOn;

    private String approvalNotes;

    @ManyToOne
    @JoinColumn(name = "driver_entity_id", referencedColumnName = "entity_id")
    private DriverEntity driver;

    @OneToMany(mappedBy = "vehicle", cascade = CascadeType.DETACH, orphanRemoval = true)
    private List<DeliveryEntity> deliveries;

    @OneToMany(mappedBy = "vehicle", cascade = CascadeType.DETACH, orphanRemoval = true)
    private List<AvailableDriverEntity> appliedDeliveries;

}
