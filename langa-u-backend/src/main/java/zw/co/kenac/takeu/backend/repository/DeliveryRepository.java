package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryRepository extends JpaRepository<DeliveryEntity, Long> {
    List<DeliveryEntity> findAllByVehicleEntityId(Long vehicleEntityId);

    @Query("SELECT d FROM DeliveryEntity d WHERE d.customer.entityId = :clientId order by d.deliveryDate desc")
    Page<DeliveryEntity> findAllByCustomerEntityId(Pageable pageable, Long clientId);

    @Query("SELECT d FROM DeliveryEntity d WHERE d.customer.entityId = :clientId AND (d.deliveryStatus='OPEN' OR d.deliveryStatus='ASSIGNED' OR d.deliveryStatus='PICKED_UP') ORDER BY d.createdAt desc ")
    Page<DeliveryEntity> findAllActiveCustomerDeliveries(Pageable pageable, Long clientId);

    @Query("SELECT d FROM DeliveryEntity d WHERE d.customer.entityId = :clientId AND d.deliveryStatus = :status")

    Page<DeliveryEntity> findAllByCustomerEntityIdAndStatus(Pageable pageable, Long clientId, String status);

    @Query("SELECT d FROM DeliveryEntity d WHERE d.driver = null AND d.deliveryStatus = 'OPEN'")
    Page<DeliveryEntity> findAllDriverOpenDeliveries(Pageable pageable);

    @Query("SELECT d FROM DeliveryEntity d WHERE d.driver.entityId = :driverId AND d.deliveryStatus = :status")
    Page<DeliveryEntity> findAllByDriverIdAndStatus(Pageable pageable, Long driverId, String status);

    @Query("SELECT d FROM DeliveryEntity d WHERE d.driver.entityId = :driverId ")
    Page<DeliveryEntity> findDeliveryEntityByDriverId(Pageable pageable, Long driverId);
    @Query("SELECT d FROM DeliveryEntity d WHERE d.deliveryStatus = :status AND d.vehicleType = :vehicleType AND d.autoAssignDriver=false ")
    Page<DeliveryEntity> findAllDeliveriesByStatusAndVehicleType(Pageable pageable,
                                                                 @Param("status") String status,
                                                                 @Param("vehicleType") String vehicleType);


    @Query("SELECT d FROM DeliveryEntity d WHERE d.driver.entityId = :driverId AND (d.deliveryStatus = :status1 OR d.deliveryStatus = :status2)")
    Page<DeliveryEntity> findAllDeliveriesAssignedToDriver(Pageable pageable,
                                                           @Param("driverId") Long driverId,
                                                           @Param("status1") String status1,
                                                           @Param("status2") String status2);
    @Query("SELECT d FROM DeliveryEntity d WHERE d.deliveryStatus = :status")
    Page<DeliveryEntity> findAllByStatus(Pageable pageable, String status);

    @Query("SELECT COUNT(d)  FROM DeliveryEntity d WHERE d.deliveryStatus =:status AND d.driver.entityId=:driverEntityId ")
    Optional<Integer> findTotalNumberOfCompleteDeliveryByDriver(@Param("status")String status,@Param("driverEntityId") Long driverEntityId);

}
