package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Entity
@Getter
@Setter
@Table(name = "ms_driver")
public class DriverEntity extends AbstractEntity {

    private String firstname;

    private String lastname;

    private String mobileNumber;

    private String email;

    private String middleName;

    private String gender;
    private Boolean isBusy;
    private Boolean isOnline;


    private String address;

    private String nationalIdNo;

    private String driverLicenseNo;
    private Boolean onlineStatus = false;
    private Double searchRadiusInKm;

    private String approvalStatus;

    private String approvedBy;

    private LocalDateTime dateApproved;

    private String approvalReason;

    private String profilePhotoUrl;

    private String nationalIdImage;

    private String driversLicenseUrl;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_entity_id", referencedColumnName = "entity_id")
    private UserEntity userEntity;

    @OneToMany(mappedBy = "driver", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<VehicleEntity> vehicles;

    @OneToMany(mappedBy = "driver", cascade = CascadeType.DETACH)
    private List<WaterDelivery> deliveries;

    @OneToMany(mappedBy = "driver")
    private List<AvailableDriverEntity> availableDrivers;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id")
    private WalletAccount wallet;

    public VehicleEntity findActiveVehicle() {
        return this.vehicles.stream()
                .filter(VehicleEntity::getActive)
                .findFirst().orElse(null);
        //.orElseThrow(() -> new ResourceNotFoundException("Driver does not have an active vehicle."));
    }

}
