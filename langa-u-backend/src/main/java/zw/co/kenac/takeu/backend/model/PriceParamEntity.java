package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Entity;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PriceParamEntity extends AbstractEntity {

    private BigDecimal pricePerKm;

    private String sensitivity;

    private String vehicleType;

}