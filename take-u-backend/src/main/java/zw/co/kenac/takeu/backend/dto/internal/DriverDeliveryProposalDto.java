package zw.co.kenac.takeu.backend.dto.internal;


import lombok.*;
import zw.co.kenac.takeu.backend.dto.client.DriverActiveVehicle;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 24/5/2025
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Setter
public class DriverDeliveryProposalDto {

    private Long driverID;
    private Long deliveryID;
    private Long proposalID;
//    private String email;
 //   private String phoneNumber;
    private String firstname;
    private String lastname;
  //  private String gender;
    private String profilePhotoUrl;
    private double rating;
    private String status;
    private double longitude;
    private double latitude;
    private long totalDeliveries;
    private DriverActiveVehicle activeVehicle;


}
