package zw.co.kenac.takeu.backend.event.listener;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import zw.co.kenac.takeu.backend.dto.DeliveryClientResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryVehicleResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.event.deliveryEvents.*;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.DriverProposalStatus;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.service.internal.FirebaseService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 24/5/2025
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DeliveryEventListeners {
    private final DeliveryRepository deliveryRepository;
    private final FirebaseService firebaseService;
    private final JavaMailService javaMailService;

    @EventListener(DeliveryCreatedEvent.class)
    private void processDeliveryCreatedEvent(DeliveryCreatedEvent event) {
        firebaseService.createDelivery(event.getDelivery());
    }

    @EventListener(DeliveryDeleteEvent.class)
    private void processDeliveryDeleteEvent(DeliveryDeleteEvent event) {
        firebaseService.deleteDelivery(event.getId(), event.getVehicleType());
    }

    @EventListener(DeliveryPickedUpEvent.class)
    private void processDeliveryPickedUpEvent(DeliveryPickedUpEvent event) {
        javaMailService.sendDeliveryCompletionOtp(event.getDeliveryId());
        firebaseService.updateActiveDeliveriesStatuses(event.getDeliveryId(), event.getDeliveryStatus());
    }

    @EventListener(DeliveryCompletedEvent.class)
    private void processDeliveryCompletedEvent(DeliveryCompletedEvent event) {
        javaMailService.sendDeliveryCompletionEmail(event.getDeliveryId());
        firebaseService.updateActiveDeliveriesStatuses(event.getDeliveryId(), event.getDeliveryStatus());
    }

    @EventListener(DriverDeliveryCancelEvents.class)
    private void processDriverDeliveryCancelEvent(DriverDeliveryCancelEvents event) {
        DeliveryEntity delivery = deliveryRepository.findById(event.getDeliveryId())
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found with id " + event.getDeliveryId()));

        // Update the active delivery status to cancelled
        firebaseService.updateActiveDeliveriesStatuses(delivery.getEntityId(), DeliveryStatus.CANCELLED);

        // Convert the delivery to DriverDeliveryResponse
        DriverDeliveryResponse deliveryResponse = new DriverDeliveryResponse(
                delivery.getEntityId(),
                delivery.getPriceAmount(),
                delivery.getPayment().getCurrency(),
                delivery.getSensitivity(),
                delivery.getPayment().getPaymentStatus(),
                delivery.getPickupLocation().getPickupLatitude(),
                delivery.getPickupLocation().getPickupLongitude(),
                delivery.getPickupLocation().getPickupLocation(),
                delivery.getPickupLocation().getPickupContactName(),
                delivery.getPickupLocation().getPickupContactPhone(),
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude(),
                delivery.getDropOffLocation().getDropOffLocation(),
                delivery.getDropOffLocation().getDropOffContactName(),
                delivery.getDropOffLocation().getDropOffContactPhone(),
                delivery.getDeliveryInstructions(),
                delivery.getParcelDescription(),
                delivery.getVehicleType(),
                delivery.getPayment().getPaymentMethod(),
                delivery.getPackageWeight(),
                DeliveryStatus.CANCELLED.name(),
                delivery.getCommissionRequired(),
                delivery.getCustomer() != null ? new DeliveryClientResponse(
                        delivery.getCustomer().getEntityId(),
                        delivery.getCustomer().getFirstname(),
                        delivery.getCustomer().getLastname(),
                        delivery.getCustomer().getMobileNumber(),
                        delivery.getCustomer().getEmailAddress()
                ) : null,
                delivery.getVehicle() != null ? new DeliveryVehicleResponse(
                        delivery.getVehicle().getEntityId(),
                        delivery.getVehicle().getVehicleModel(),
                        delivery.getVehicle().getVehicleColor(),
                        delivery.getVehicle().getVehicleMake(),
                        delivery.getVehicle().getLicensePlateNo(),
                        delivery.getVehicle().getVehicleType()
                ) : null,
                delivery.getIsScheduled()
                , delivery.getPickUpTime()
                ,delivery.getCreatedAt()
                ,delivery.getUpdatedAt()
        );

        // Create the delivery using processDeliveryCreatedEvent
        processDeliveryCreatedEvent(new DeliveryCreatedEvent(this, deliveryResponse));

        // Mark the current accepted proposal as cancelled
        if (delivery.getDriver() != null) {
            firebaseService.updateDeliveryProposalStatuses(
                    delivery.getEntityId(),
                    delivery.getDriver().getEntityId(),
                    DriverProposalStatus.CANCELLED.name(),
                    DriverProposalStatus.CANCELLED.name()
            );
        }
    }

    @EventListener(ClientDeliveryCancelEvent.class)
    private void processClientDeliveryCancelEvent(ClientDeliveryCancelEvent event) {
        DeliveryEntity delivery;
        if (event.getDelivery() != null) {
            delivery = event.getDelivery();
        } else {
            delivery = deliveryRepository.findById(event.getDeliveryId()).orElseThrow(() -> new ResourceNotFoundException("Delivery not found with id " + event.getDeliveryId()));
        }


        if (event.getCurrentStatus().equals(DeliveryStatus.ASSIGNED)) {// meaning to say that the it was cancelled after driver has been assigned
            firebaseService.updateActiveDeliveriesStatuses(delivery.getEntityId(), DeliveryStatus.CANCELLED);
            firebaseService.updateDeliveryProposalStatuses(
                    delivery.getEntityId(),
                    delivery.getDriver().getEntityId(),
                    DriverProposalStatus.CANCELLED.name(),
                    DriverProposalStatus.CANCELLED.name()
            );
        } else {
            // means that the driver hasnt be accepted but panokwanisa kuva nema proposals
            firebaseService.deleteDelivery(delivery.getEntityId(), delivery.getVehicleType());// delete the ride completely

            //update proposals
            firebaseService.updateDeliveryProposalStatuses(delivery.getEntityId(), 0L,
                    DriverProposalStatus.CANCELLED.name(),
                    DriverProposalStatus.CANCELLED.name());
        }


    }
}
