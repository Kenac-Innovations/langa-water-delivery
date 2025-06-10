package zw.co.kenac.takeu.backend.event.listener;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DriverAcceptedEvent;
import zw.co.kenac.takeu.backend.event.deliveryproposalevents.ProposalCreatedEvent;
import zw.co.kenac.takeu.backend.event.deliveryproposalevents.ProposalDeletedEvent;
import zw.co.kenac.takeu.backend.model.enumeration.DriverProposalStatus;
import zw.co.kenac.takeu.backend.service.internal.FirebaseService;

@Slf4j
@Component
@RequiredArgsConstructor
public class ProposalEventListeners {
    private final FirebaseService firebaseService;

    @EventListener(classes = ProposalCreatedEvent.class)
    public void handleProposalCreatedEvent(ProposalCreatedEvent event) {
        log.info("Received proposal created event for delivery: {} and driver: {}",
                event.getProposal().getDeliveryID(),
                event.getProposal().getDriverID());

        try {
            firebaseService.createDriverDeliveryProposal(event.getProposal());
            log.info("Successfully processed proposal created event");
        } catch (Exception e) {
            log.error("Error processing proposal created event: {}", e.getMessage());
        }
    }

    @EventListener(classes = ProposalDeletedEvent.class)
    public void handleProposalDeletedEvent(ProposalDeletedEvent event) {
        log.info("Received proposal deleted event for proposal: {} and delivery: {}",
                event.getProposalId(),
                event.getDeliveryId());

        try {
            firebaseService.deleteDriverDeliveryProposal(event.getProposalId());
            log.info("Successfully processed proposal deleted event");
        } catch (Exception e) {
            log.error("Error processing proposal deleted event: {}", e.getMessage());
        }
    }
    @EventListener(DriverAcceptedEvent.class)
    public void handleDriverAcceptedEvent(DriverAcceptedEvent event) {
        Long proposalId = event.getAvailableDriver().getEntityId();
        Long deliveryId = event.getAvailableDriver().getDelivery().getEntityId();

        log.info("=========> ➡️ [DriverAcceptedEvent] Received event - Proposal ID: {}, Delivery ID: {}", proposalId, deliveryId);

        try {
            firebaseService.updateDeliveryProposalStatuses(
                    deliveryId,
                    proposalId,
                    DriverProposalStatus.ACCEPTED.name(),
                    DriverProposalStatus.DECLINED.name()
            );
            firebaseService.createActiveDeliveries(deliveryId);// this is to put in active
            log.info("======== > ✅ [DriverAcceptedEvent] Updated Firebase - Proposal ID: {} set to '{}', others to '{}'",
                    proposalId,
                    DriverProposalStatus.ACCEPTED.name(),
                    DriverProposalStatus.DECLINED.name());
        } catch (Exception e) {
            log.error("========> ❌ [DriverAcceptedEvent] Failed to update Firebase for Delivery ID: {}, Proposal ID: {}. Reason: {}",
                    deliveryId,
                    proposalId,
                    e.getMessage(), e);
        }
    }
} 