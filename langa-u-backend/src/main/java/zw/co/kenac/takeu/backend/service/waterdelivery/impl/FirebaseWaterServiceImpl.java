package zw.co.kenac.takeu.backend.service.waterdelivery.impl;

import com.github.davidmoten.geo.GeoHash;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.FirebaseDriverDeliveryProposalsDto;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryProposalDto;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.event.deliveryproposalevents.ProposalDeletedEvent;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.GenericStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.service.internal.FirebaseService;
import zw.co.kenac.takeu.backend.service.waterdelivery.FirebaseWaterService;
import zw.co.kenac.takeu.backend.walletmodule.dto.CreateFirebaseTransactionDTO;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class FirebaseWaterServiceImpl implements FirebaseWaterService {

    private final FirebaseDatabase firebaseDatabase;
    private final ApplicationEventPublisher eventPublisher;
    private final DeliveryRepository deliveryRepository;
    private final String OPENDELIVERY = "opendelivery";

    @Override
    public void createTransaction(CreateFirebaseTransactionDTO transaction) {
        try {
            DatabaseReference transactionsRef = firebaseDatabase.getReference("transactions");
            DatabaseReference transactionRef = transactionsRef.child(transaction.getTransactionId());

            Map<String, Object> transactionData = new HashMap<>();
            transactionData.put("reference", transaction.getReference());
            transactionData.put("amount", transaction.getAmount().toString());
            transactionData.put("status", transaction.getStatus().name());
            transactionData.put("narration", transaction.getNarration());
            transactionData.put("paymentMethod", transaction.getPaymentMethod());
            transactionData.put("currency", transaction.getCurrency());
            transactionData.put("clientId", transaction.getClientId());
            transactionData.put("driverId", transaction.getDriverId());
            transactionData.put("createdAt", LocalDateTime.now().toString());
            transactionData.put("updatedAt", LocalDateTime.now().toString());

            transactionRef.setValue(transactionData, (error, ref) -> {
                if (error != null) {
                    log.error("======> Failed to create transaction in Firebase: {}", error.getMessage());
                } else {
                    log.info("====> Successfully created transaction in Firebase with ID: {}", transaction.getTransactionId());
                }
            });
        } catch (Exception e) {
            log.error("Error creating transaction in Firebase: {}", e.getMessage());
            throw new RuntimeException("Error creating transaction in Firebase", e);
        }
    }

    @Override
    public void createDelivery(WaterDelivery delivery) {
        try {
            DatabaseReference deliveriesRef = firebaseDatabase.getReference(OPENDELIVERY);
            DatabaseReference deliveryRef = deliveriesRef.child(String.valueOf(delivery.getEntityId()));

            // Generate geohash for dropoff location
            String dropoffGeohash = GeoHash.encodeHash(
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude(),
                9
            );

            Map<String, Object> deliveryData = new HashMap<>();
            deliveryData.put("id", delivery.getEntityId());
            deliveryData.put("priceAmount", delivery.getPriceAmount().toString());
            deliveryData.put("autoAssignDriver", delivery.getAutoAssignDriver());
            deliveryData.put("isScheduled", delivery.getIsScheduled());
            deliveryData.put("deliveryInstructions", delivery.getDeliveryInstructions());
            deliveryData.put("deliveryStatus", delivery.getDeliveryStatus());
            deliveryData.put("commissionRequired", delivery.getCommissionRequired() != null ? 
                delivery.getCommissionRequired().toString() : "0");
            deliveryData.put("createdAt", LocalDateTime.now().toString());

            // Add dropoff location data
            if (delivery.getDropOffLocation() != null) {
                Map<String, Object> dropoffData = new HashMap<>();
                dropoffData.put("dropOffLatitude", delivery.getDropOffLocation().getDropOffLatitude());
                dropoffData.put("dropOffLongitude", delivery.getDropOffLocation().getDropOffLongitude());
                dropoffData.put("dropOffLocation", delivery.getDropOffLocation().getDropOffLocation());
                dropoffData.put("dropOffAddressType", delivery.getDropOffLocation().getDropOffAddressType());
                dropoffData.put("dropOffContactName", delivery.getDropOffLocation().getDropOffContactName());
                dropoffData.put("dropOffContactPhone", delivery.getDropOffLocation().getDropOffContactPhone());
                deliveryData.put("dropOffLocation", dropoffData);
            }

            // Add scheduled details if available
            if (delivery.getScheduledDetails() != null) {
                Map<String, Object> scheduledData = new HashMap<>();
                scheduledData.put("scheduledDate", delivery.getScheduledDetails().getScheduledDate());
                scheduledData.put("scheduledTime", delivery.getScheduledDetails().getScheduledTime());
                deliveryData.put("scheduledDetails", scheduledData);
            }

            // Add client information if available
            if (delivery.getOrder() != null && delivery.getOrder().getClient() != null) {
                Map<String, Object> clientData = new HashMap<>();
                clientData.put("id", delivery.getOrder().getClient().getEntityId());
                clientData.put("fullName", delivery.getOrder().getClient().getFullName());
                clientData.put("mobileNumber", delivery.getOrder().getClient().getMobileNumber());
                deliveryData.put("client", clientData);
            }

//            // Add driver information if available
//            if (delivery.getDriver() != null) {
//                Map<String, Object> driverData = new HashMap<>();
//                driverData.put("id", delivery.getDriver().getEntityId());
//                driverData.put("firstname", delivery.getDriver().getFirstname());
//                driverData.put("lastname", delivery.getDriver().getLastname());
//                driverData.put("mobileNumber", delivery.getDriver().getMobileNumber());
//                driverData.put("profilePhotoUrl", delivery.getDriver().getProfilePhotoUrl());
//                deliveryData.put("driver", driverData);
//            }

            // Add vehicle information if available
//            if (delivery.getVehicle() != null) {
//                Map<String, Object> vehicleData = new HashMap<>();
//                vehicleData.put("id", delivery.getVehicle().getEntityId());
//                vehicleData.put("vehicleModel", delivery.getVehicle().getVehicleModel());
//                vehicleData.put("vehicleColor", delivery.getVehicle().getVehicleColor());
//                vehicleData.put("vehicleMake", delivery.getVehicle().getVehicleMake());
//                vehicleData.put("licensePlateNo", delivery.getVehicle().getLicensePlateNo());
//                vehicleData.put("vehicleType", delivery.getVehicle().getVehicleType());
//                deliveryData.put("vehicle", vehicleData);
//            }

            // Add geohash data
            deliveryData.put("g", dropoffGeohash);
            deliveryData.put("l", List.of(
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude()
            ));

            deliveryRef.setValue(deliveryData, (error, ref) -> {
                if (error != null) {
                    log.error("Failed to create water delivery in Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully created water delivery in Firebase with ID: {}", delivery.getEntityId());
                }
            });
        } catch (Exception e) {
            log.error("Error creating water delivery in Firebase: {}", e.getMessage());
            throw new RuntimeException("Error creating water delivery in Firebase", e);
        }
    }

    @Override
    public void updateTransactionStatus(String transactionId, TransactionStatus status, String narration) {
        try {
            DatabaseReference transactionsRef = firebaseDatabase.getReference("transactions");// this is the node tree name
            DatabaseReference transactionRef = transactionsRef.child(transactionId);

            Map<String, Object> updates = new HashMap<>();
            updates.put("status", status.name());
            updates.put("narration", narration);
            updates.put("updatedAt", LocalDateTime.now().toString());

            // First check if the transaction exists
            transactionRef.addListenerForSingleValueEvent(new com.google.firebase.database.ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) {

                        updates.put("createdAt", LocalDateTime.now().toString());
                    }
                    // Update the transaction data
                    transactionRef.updateChildren(updates, (error, ref) -> {
                        if (error != null) {
                            log.error("========> Failed to update transaction status in Firebase for transaction: {}", transactionId, error);
                        } else {
                            log.info("Successfully updated transaction status in Firebase for transaction: {}", transactionId);
                        }
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {
                    log.error("Failed to check transaction existence in Firebase for transaction: {}", transactionId, error.toException());
                }
            });

        } catch (Exception e) {
            log.error("Error updating transaction status in Firebase for transaction: {}", transactionId, e);
        }
    }

    @Override
    public void deleteDelivery(Long deliveryId, String vehicleType) {
        try {
            // Determine the bucket based on vehicle type
            String bucketName = "openDeliveries";
            if (vehicleType != null) {
                if (vehicleType.equalsIgnoreCase("BIKE")) {
                    bucketName = "openDeliveryBikes";
                } else if (vehicleType.equalsIgnoreCase("CAR")) {
                    bucketName = "openDeliveryCars";
                }
            }

            DatabaseReference deliveriesRef = firebaseDatabase.getReference(bucketName);
            DatabaseReference deliveryRef = deliveriesRef.child(String.valueOf(deliveryId));

            String finalBucketName = bucketName;
            deliveryRef.removeValue((error, ref) -> {
                if (error != null) {
                    log.error("Failed to delete delivery from Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully deleted delivery from Firebase with ID: {} from bucket: {}", 
                        deliveryId, finalBucketName);
                }
            });
        } catch (Exception e) {
            log.error("Error deleting delivery from Firebase: {}", e.getMessage());
            throw new RuntimeException("Error deleting delivery from Firebase", e);
        }
    }

    @Override
    public void createDriverDeliveryProposal(DriverDeliveryProposalDto proposal) {
        try {
            DatabaseReference proposalsRef = firebaseDatabase.getReference("deliveryProposals");
            DatabaseReference deliveryProposalsRef = proposalsRef.child(String.valueOf(proposal.getDeliveryID()));

            // Create a map for the proposal data
            Map<String, Object> proposalData = new HashMap<>();
            proposalData.put("driverID", proposal.getDriverID());
            proposalData.put("proposalID", proposal.getProposalID());
            proposalData.put("firstname", proposal.getFirstname());
            proposalData.put("lastname", proposal.getLastname());
            proposalData.put("profilePhotoUrl", proposal.getProfilePhotoUrl());
            proposalData.put("rating", proposal.getRating());
            proposalData.put("status", proposal.getStatus());
            proposalData.put("longitude", proposal.getLongitude());
            proposalData.put("latitude", proposal.getLatitude());
            proposalData.put("totalDeliveries", proposal.getTotalDeliveries());
            
            // Add vehicle information if available
            if (proposal.getActiveVehicle() != null) {
                Map<String, Object> vehicleData = new HashMap<>();
                vehicleData.put("vehicleId", proposal.getActiveVehicle().getVehicleId());
                vehicleData.put("vehicleModel", proposal.getActiveVehicle().getVehicleModel());
                vehicleData.put("vehicleColor", proposal.getActiveVehicle().getVehicleColor());
                vehicleData.put("vehicleMake", proposal.getActiveVehicle().getVehicleMake());
                vehicleData.put("licensePlateNo", proposal.getActiveVehicle().getLicensePlateNo());
                vehicleData.put("vehicleType", proposal.getActiveVehicle().getVehicleType());
                proposalData.put("activeVehicle", vehicleData);
            }

            // Add timestamp
            proposalData.put("createdAt", LocalDateTime.now().toString());

            // Use the proposal ID as the key for this specific proposal
            DatabaseReference proposalRef = deliveryProposalsRef.child(String.valueOf(proposal.getProposalID()));
            
            proposalRef.setValue(proposalData, (error, ref) -> {
                if (error != null) {
                    log.error("Failed to create delivery proposal in Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully created delivery proposal in Firebase for delivery: {} and driver: {}", 
                        proposal.getDeliveryID(), proposal.getDriverID());
                    
                    // Add to driver proposals after successful creation
                    FirebaseDriverDeliveryProposalsDto driverProposalDto = new FirebaseDriverDeliveryProposalsDto(
                        proposal.getDriverID(),
                        proposal.getDeliveryID(),
                        GenericStatus.OPEN,
                        proposal.getProposalID()
                    );
                    addToDriverProposalForDelivery(driverProposalDto);
                }
            });
        } catch (Exception e) {
            log.error("Error creating delivery proposal in Firebase: {}", e.getMessage());
            throw new RuntimeException("Error creating delivery proposal in Firebase", e);
        }
    }

    @Override
    public void deleteDriverDeliveryProposal(Long proposalId) {
        try {
            DatabaseReference proposalsRef = firebaseDatabase.getReference("deliveryProposals");
            
            // First, we need to find which delivery this proposal belongs to
            proposalsRef.addListenerForSingleValueEvent(new com.google.firebase.database.ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    for (DataSnapshot deliverySnapshot : snapshot.getChildren()) {
                        DataSnapshot proposalSnapshot = deliverySnapshot.child(String.valueOf(proposalId));
                        if (proposalSnapshot.exists()) {
                            // Found the proposal, now delete it
                            proposalSnapshot.getRef().removeValue((error, ref) -> {
                                if (error != null) {
                                    log.error("Failed to delete delivery proposal from Firebase: {}", error.getMessage());
                                } else {
                                    log.info("Successfully deleted delivery proposal from Firebase with ID: {}", proposalId);
                                    // Publish event after successful deletion
                                    eventPublisher.publishEvent(new ProposalDeletedEvent(this, proposalId, 
                                        Long.parseLong(deliverySnapshot.getKey())));
                                }
                            });
                            return;
                        }
                    }
                    log.warn("No proposal found with ID: {}", proposalId);
                }

                @Override
                public void onCancelled(DatabaseError error) {
                    log.error("Failed to search for proposal in Firebase: {}", error.getMessage());
                }
            });
        } catch (Exception e) {
            log.error("Error deleting delivery proposal from Firebase: {}", e.getMessage());
            throw new RuntimeException("Error deleting delivery proposal from Firebase", e);
        }
    }
    @Override
    public void updateDeliveryProposalStatuses(Long deliveryId, Long acceptedProposalId, String acceptedStatus, String declinedStatus) {
        try {
            DatabaseReference proposalsRef = firebaseDatabase.getReference("deliveryProposals");
            DatabaseReference deliveryProposalsRef = proposalsRef.child(String.valueOf(deliveryId));

            deliveryProposalsRef.addListenerForSingleValueEvent(new com.google.firebase.database.ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) {
                        log.warn("=======> No proposals found for delivery ID: {}", deliveryId);
                        return;
                    }

                    Map<String, Object> updates = new HashMap<>();
                    boolean acceptedProposalFound = false;

                    // Iterate through all proposals for this delivery
                    for (DataSnapshot proposalSnapshot : snapshot.getChildren()) {
                        String proposalId = proposalSnapshot.getKey();

                        if (proposalId != null) {
                            if (proposalId.equals(String.valueOf(acceptedProposalId))) {
                                // This is the proposal to accept
                                updates.put(proposalId + "/status", acceptedStatus);
                                updates.put(proposalId + "/updatedAt", LocalDateTime.now().toString());
                                acceptedProposalFound = true;
                                log.debug("========> Marking proposal {} as {}", proposalId, acceptedStatus);
                            } else {
                                // These are the proposals to decline/cancel
                                updates.put(proposalId + "/status", declinedStatus);
                                updates.put(proposalId + "/updatedAt", LocalDateTime.now().toString());
                                log.debug("=======> Marking proposal {} as {}", proposalId, declinedStatus);
                                
                                // Delete from driver proposals for declined proposals
                                Long driverId = proposalSnapshot.child("driverID").getValue(Long.class);
                                if (driverId != null) {
                                    FirebaseDriverDeliveryProposalsDto dto = new FirebaseDriverDeliveryProposalsDto(
                                        driverId,
                                        deliveryId,
                                        GenericStatus.DECLINED,
                                        Long.parseLong(proposalId)
                                    );
                                    deleteDriverProposalForDelivery(dto);
                                }
                            }
                        }
                    }

                    if (!acceptedProposalFound) {
                        log.warn("=========>Accepted proposal ID {} not found for delivery {}", acceptedProposalId, deliveryId);
                        return;
                    }

                    // Apply all updates atomically
                    deliveryProposalsRef.updateChildren(updates, (error, ref) -> {
                        if (error != null) {
                            log.error("========> Failed to update proposal statuses for delivery {}: {}", deliveryId, error.getMessage());
                        } else {
                            log.info("========> Successfully updated proposal statuses for delivery {}. Accepted: {}, Declined: {} proposals",
                                    deliveryId, 1, updates.size() / 2 - 1); // Divide by 2 because we update both status and updatedAt
                            
                            // Delete from driver proposals for the accepted proposal
                            DataSnapshot acceptedProposal = snapshot.child(String.valueOf(acceptedProposalId));
                            if (acceptedProposal.exists()) {
                                Long driverId = acceptedProposal.child("driverID").getValue(Long.class);
                                if (driverId != null) {
                                    FirebaseDriverDeliveryProposalsDto dto = new FirebaseDriverDeliveryProposalsDto(
                                        driverId,
                                        deliveryId,
                                        GenericStatus.ACCEPTED,
                                        acceptedProposalId
                                    );
                                    deleteDriverProposalForDelivery(dto);
                                }
                            }
                        }
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {
                    log.error("========> Failed to read proposals for delivery {}: {}", deliveryId, error.getMessage());
                }
            });

        } catch (Exception e) {
            log.error("=======> Error updating delivery proposal statuses for delivery {}: {}", deliveryId, e.getMessage());
            throw new RuntimeException("Error updating delivery proposal statuses", e);
        }
    }

    @Override
    public void createActiveDeliveries(WaterDelivery delivery) {
        try {
            // Create a reference to the active deliveries node
            DatabaseReference activeDeliveriesRef = firebaseDatabase.getReference("activeDeliveries");
            DatabaseReference deliveryRef = activeDeliveriesRef.child(String.valueOf(delivery.getEntityId()));

            Map<String, Object> deliveryData = new HashMap<>();
            deliveryData.put("id", delivery.getEntityId());
            deliveryData.put("priceAmount", delivery.getPriceAmount().toString());
            deliveryData.put("autoAssignDriver", delivery.getAutoAssignDriver());
            deliveryData.put("isScheduled", delivery.getIsScheduled());
            deliveryData.put("deliveryInstructions", delivery.getDeliveryInstructions());
            deliveryData.put("deliveryStatus", delivery.getDeliveryStatus());
            deliveryData.put("commissionRequired", delivery.getCommissionRequired() != null ? 
                delivery.getCommissionRequired().toString() : "0");
            deliveryData.put("createdAt", LocalDateTime.now().toString());

            // Add dropoff location data
            if (delivery.getDropOffLocation() != null) {
                Map<String, Object> dropoffData = new HashMap<>();
                dropoffData.put("dropOffLatitude", delivery.getDropOffLocation().getDropOffLatitude());
                dropoffData.put("dropOffLongitude", delivery.getDropOffLocation().getDropOffLongitude());
                dropoffData.put("dropOffLocation", delivery.getDropOffLocation().getDropOffLocation());
                dropoffData.put("dropOffAddressType", delivery.getDropOffLocation().getDropOffAddressType());
                dropoffData.put("dropOffContactName", delivery.getDropOffLocation().getDropOffContactName());
                dropoffData.put("dropOffContactPhone", delivery.getDropOffLocation().getDropOffContactPhone());
                deliveryData.put("dropOffLocation", dropoffData);
            }

            // Add scheduled details if available
            if (delivery.getScheduledDetails() != null) {
                Map<String, Object> scheduledData = new HashMap<>();
                scheduledData.put("scheduledDate", delivery.getScheduledDetails().getScheduledDate());
                scheduledData.put("scheduledTime", delivery.getScheduledDetails().getScheduledTime());
                deliveryData.put("scheduledDetails", scheduledData);
            }

            // Add client information if available
            if (delivery.getOrder() != null && delivery.getOrder().getClient() != null) {
                Map<String, Object> clientData = new HashMap<>();
                clientData.put("id", delivery.getOrder().getClient().getEntityId());
                clientData.put("fullName", delivery.getOrder().getClient().getFullName());
                clientData.put("mobileNumber", delivery.getOrder().getClient().getMobileNumber());
                deliveryData.put("client", clientData);
            }

            // Add driver information if available
            if (delivery.getDriver() != null) {
                Map<String, Object> driverData = new HashMap<>();
                driverData.put("id", delivery.getDriver().getEntityId());
                driverData.put("firstname", delivery.getDriver().getFirstname());
                driverData.put("lastname", delivery.getDriver().getLastname());
                driverData.put("mobileNumber", delivery.getDriver().getMobileNumber());
                driverData.put("profilePhotoUrl", delivery.getDriver().getProfilePhotoUrl());
                deliveryData.put("driver", driverData);
            }

//            // Add vehicle information if available
//            if (delivery.getVehicle() != null) {
//                Map<String, Object> vehicleData = new HashMap<>();
//                vehicleData.put("id", delivery.getVehicle().getEntityId());
//                vehicleData.put("vehicleModel", delivery.getVehicle().getVehicleModel());
//                vehicleData.put("vehicleColor", delivery.getVehicle().getVehicleColor());
//                vehicleData.put("vehicleMake", delivery.getVehicle().getVehicleMake());
//                vehicleData.put("licensePlateNo", delivery.getVehicle().getLicensePlateNo());
//                vehicleData.put("vehicleType", delivery.getVehicle().getVehicleType());
//                deliveryData.put("vehicle", vehicleData);
//            }

            // Add geohash data
            String dropoffGeohash = GeoHash.encodeHash(
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude(),
                9
            );
            deliveryData.put("g", dropoffGeohash);
            deliveryData.put("l", List.of(
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude()
            ));

            // Save the delivery data to Firebase
            deliveryRef.setValue(deliveryData, (error, ref) -> {
                if (error != null) {
                    log.error("Failed to create active delivery in Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully created active delivery in Firebase with ID: {}", delivery.getEntityId());
                }
            });
        } catch (Exception e) {
            log.error("Error creating active delivery in Firebase: {}", e.getMessage());
            throw new RuntimeException("Error creating active delivery in Firebase", e);
        }
    }

    @Override
    public void deleteActiveDeliveries(Long deliveryId) {
        try {
            DatabaseReference activeDeliveriesRef = firebaseDatabase.getReference("activeDeliveries");
            DatabaseReference deliveryRef = activeDeliveriesRef.child(String.valueOf(deliveryId));

            deliveryRef.removeValue((error, ref) -> {
                if (error != null) {
                    log.error("Failed to delete active delivery from Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully deleted active delivery from Firebase with ID: {}", deliveryId);
                }
            });
        } catch (Exception e) {
            log.error("Error deleting active delivery from Firebase: {}", e.getMessage());
            throw new RuntimeException("Error deleting active delivery from Firebase", e);
        }
    }

    @Override
    public void updateActiveDeliveriesStatuses(Long deliveryId, DeliveryStatus status) {
        try {
            DatabaseReference activeDeliveriesRef = firebaseDatabase.getReference("activeDeliveries");
            DatabaseReference deliveryRef = activeDeliveriesRef.child(String.valueOf(deliveryId));

            Map<String, Object> updates = new HashMap<>();
            updates.put("deliveryStatus", status.name());
            updates.put("updatedAt", LocalDateTime.now().toString());

            deliveryRef.updateChildren(updates, (error, ref) -> {
                if (error != null) {
                    log.error("=======> Failed to update active delivery status in Firebase: {}", error.getMessage());
                } else {
                    log.info("========> Successfully updated active delivery status in Firebase for delivery ID: {}", deliveryId);
                }
            });
        } catch (Exception e) {
            log.error("===========> Error updating active delivery status in Firebase: {}", e.getMessage());
            throw new RuntimeException("Error updating active delivery status in Firebase", e);
        }
    }

    @Override
    public void addToDriverProposalForDelivery(FirebaseDriverDeliveryProposalsDto dto) {
        try {
            DatabaseReference driverProposalsRef = firebaseDatabase.getReference("driverDeliveriesProposals");
            DatabaseReference driverRef = driverProposalsRef.child(String.valueOf(dto.getDriverId()));
            DatabaseReference deliveryRef = driverRef.child(String.valueOf(dto.getDeliveryId()));

            Map<String, Object> proposalData = new HashMap<>();
            proposalData.put("status", dto.getStatus().name());
            proposalData.put("proposalId", dto.getProposalId());
            proposalData.put("createdAt", LocalDateTime.now().toString());

            deliveryRef.setValue(proposalData, (error, ref) -> {
                if (error != null) {
                    log.error("Failed to add driver proposal for delivery in Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully added driver proposal for delivery in Firebase - Driver: {}, Delivery: {}", 
                        dto.getDriverId(), dto.getDeliveryId());
                }
            });
        } catch (Exception e) {
            log.error("Error adding driver proposal for delivery in Firebase: {}", e.getMessage());
            throw new RuntimeException("Error adding driver proposal for delivery in Firebase", e);
        }
    }

    @Override
    public void deleteDriverProposalForDelivery(FirebaseDriverDeliveryProposalsDto dto) {
        try {
            DatabaseReference driverProposalsRef = firebaseDatabase.getReference("driverDeliveriesProposals");
            DatabaseReference driverRef = driverProposalsRef.child(String.valueOf(dto.getDriverId()));
            DatabaseReference deliveryRef = driverRef.child(String.valueOf(dto.getDeliveryId()));

            deliveryRef.removeValue((error, ref) -> {
                if (error != null) {
                    log.error("Failed to delete driver proposal for delivery from Firebase: {}", error.getMessage());
                } else {
                    log.info("Successfully deleted driver proposal for delivery from Firebase - Driver: {}, Delivery: {}", 
                        dto.getDriverId(), dto.getDeliveryId());
                }
            });
        } catch (Exception e) {
            log.error("Error deleting driver proposal for delivery from Firebase: {}", e.getMessage());
            throw new RuntimeException("Error deleting driver proposal for delivery from Firebase", e);
        }
    }
} 