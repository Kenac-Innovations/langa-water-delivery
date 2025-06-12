package zw.co.kenac.takeu.backend.model;

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
@Table(name = "st_vehicle_type")
public class VehicleTypeEntity extends AbstractEntity {

    private String name;

    private Boolean active;

    @OneToMany(mappedBy = "vehicleType")
    private List<VehicleEntity> vehicle;

}
