package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.FirebaseDriverDeliveryProposalsDto;
import zw.co.kenac.takeu.backend.dto.client.AvailableDriverResponse;
import zw.co.kenac.takeu.backend.dto.client.ClientDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryProposalDto;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponseWithProposal;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.walletmodule.dto.CreateFirebaseTransactionDTO;

public interface FirebaseService {
    void updateTransactionStatus(String transactionId, TransactionStatus status, String narration);
    void createTransaction(CreateFirebaseTransactionDTO transaction);
    void createDelivery(DriverDeliveryResponse deliveryResponse);
    void deleteDelivery(Long deliveryId,String vehicleType);
    void createDriverDeliveryProposal(DriverDeliveryProposalDto proposal);
    void updateDeliveryProposalStatuses(Long deliveryId, Long acceptedProposalId, String acceptedStatus, String declinedStatus);
    void deleteDriverDeliveryProposal(Long deliveryId);

    void createActiveDeliveries(Long deliveryId);
    void deleteActiveDeliveries(Long deliveryId);
    void updateActiveDeliveriesStatuses(Long deliveryId, DeliveryStatus status);
    // driver proposals section
    void addToDriverProposalForDelivery(FirebaseDriverDeliveryProposalsDto dto);
    void deleteDriverProposalForDelivery(FirebaseDriverDeliveryProposalsDto dto);
} 