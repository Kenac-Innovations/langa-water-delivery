package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.util.List;

@Entity
@Table(name = "st_vehicle_status")
public class VehicleStatusEntity extends AbstractEntity {

    private String statusName;

    @OneToMany(mappedBy = "vehicleStatus")
    private List<VehicleEntity> vehicles;

}
