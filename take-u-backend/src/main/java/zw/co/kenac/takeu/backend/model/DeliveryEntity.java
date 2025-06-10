package zw.co.kenac.takeu.backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import zw.co.kenac.takeu.backend.model.embedded.DropOffLocation;
import zw.co.kenac.takeu.backend.model.embedded.PickupLocation;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Entity
@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "ms_deliveries")
public class DeliveryEntity extends AbstractEntity {

    @Column(precision = 30, scale = 4)
    private BigDecimal priceAmount;

    private Boolean autoAssignDriver;

    private String sensitivity;

    @Embedded
    private PickupLocation pickupLocation;

    @Embedded
    private DropOffLocation dropOffLocation;

    @Embedded
    private DeliveryPayment payment;

    private Boolean isScheduled;

    private String deliveryInstructions;

    private String parcelDescription;

    private String vehicleType;

    private LocalDateTime deliveryDate;
    private LocalTime pickUpTime;

    private String deliveryStatus;
    @Column(length = 6)
    private String completionOtp;

    @Column(precision = 30, scale = 4)
    private BigDecimal packageWeight;

    @Column(precision = 30, scale = 4)
    private BigDecimal packageHeight;

    @Column(precision = 30, scale = 4)
    private BigDecimal commissionRequired;

    @Column(columnDefinition = "TEXT")
    private String reasonForCancelling;

    @ManyToOne
    @JoinColumn(name = "customer_entity_id", referencedColumnName = "entity_id")
    private ClientEntity customer;

    @ManyToOne
    @JoinColumn(name = "driver_entity_id", referencedColumnName = "entity_id")
    private DriverEntity driver;

    @ManyToOne
    @JoinColumn(name = "vehicle_entity_id", referencedColumnName = "entity_id")
    private VehicleEntity vehicle;

    @OneToOne(mappedBy = "delivery")
    private DriverRatingEntity driverRating;

    @OneToOne(mappedBy = "delivery")
    private ClientRatingEntity clientRating;

    @OneToOne(mappedBy = "delivery")
    private PickupEntity pickup;

    @OneToOne(mappedBy = "delivery")
    @JsonBackReference
    private Transaction transaction;

    @OneToOne(mappedBy = "delivery")
    private DropOffEntity dropOff;

    @OneToMany(mappedBy = "delivery")
    private List<AvailableDriverEntity> availableDrivers;
    @CreationTimestamp
    private LocalDateTime createdAt;
    @UpdateTimestamp
    private  LocalDateTime updatedAt;
}
