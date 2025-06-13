package zw.co.kenac.takeu.backend.dto.driver;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverActiveVehicle {
    private Long vehicleId;
    private String vehicleModel;
    private String vehicleColor;
    private String vehicleMake;
    private String licensePlateNo;
    private String vehicleType;
} 