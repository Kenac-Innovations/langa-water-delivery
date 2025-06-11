package zw.co.kenac.takeu.backend.dto.driver;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverDeliveryProposalDto {
    private Long driverID;
    private Long deliveryID;
    private Long proposalID;
    private String firstname;
    private String lastname;
    private String profilePhotoUrl;
    private double rating;
    private String status;
    private double longitude;
    private double latitude;
    private long totalDeliveries;
    private DriverActiveVehicle activeVehicle;
} 