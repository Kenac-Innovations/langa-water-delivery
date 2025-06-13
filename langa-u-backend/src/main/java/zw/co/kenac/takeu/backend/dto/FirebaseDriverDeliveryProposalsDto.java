package zw.co.kenac.takeu.backend.dto;


import lombok.*;
import zw.co.kenac.takeu.backend.model.enumeration.GenericStatus;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 1/6/2025
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class FirebaseDriverDeliveryProposalsDto {
    private Long driverId;
    private Long deliveryId;
    private GenericStatus status;
    private Long proposalId;
}
