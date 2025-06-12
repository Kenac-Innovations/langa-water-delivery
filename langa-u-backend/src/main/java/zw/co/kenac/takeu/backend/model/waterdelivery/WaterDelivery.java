package zw.co.kenac.takeu.backend.model.waterdelivery;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import zw.co.kenac.takeu.backend.model.AvailableDriverEntity;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.DriverRatingEntity;
import zw.co.kenac.takeu.backend.model.VehicleEntity;
import zw.co.kenac.takeu.backend.model.base.BaseEntity;
import zw.co.kenac.takeu.backend.model.embedded.DropOffLocation;
import zw.co.kenac.takeu.backend.model.embedded.ScheduledDetails;

import java.math.BigDecimal;
import java.util.List;

@Entity
@Table(name = "water_deliveries")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@SuperBuilder
public class WaterDelivery extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private WaterOrder order;

    @Column(precision = 30, scale = 4)
    private BigDecimal priceAmount;

    private Boolean autoAssignDriver;
    @Embedded
    private DropOffLocation dropOffLocation;
    private Boolean isScheduled;
    private String deliveryInstructions;
    @Embedded
    private ScheduledDetails scheduledDetails;
    private String deliveryStatus;
    @Column(length = 6)
    private String completionOtp;
    @Column(precision = 30, scale = 4)
    private BigDecimal commissionRequired;
    @Column(columnDefinition = "TEXT")
    private String reasonForCancelling;
    @ManyToOne
    @JoinColumn(name = "driver_entity_id", referencedColumnName = "entity_id")
    private DriverEntity driver;
    @ManyToOne
    @JoinColumn(name = "vehicle_entity_id", referencedColumnName = "entity_id")
    private VehicleEntity vehicle;
    @OneToOne(mappedBy = "delivery")
    private DriverRatingEntity driverRating;


    @OneToMany(mappedBy = "delivery")
    private List<AvailableDriverEntity> availableDrivers;
} 