package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.model.AvailableDriverEntity;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.DriverEntity;

import java.util.List;
import java.util.Optional;

@Repository
public interface AvailableDriverRepository extends JpaRepository<AvailableDriverEntity, Long> {

    Optional<AvailableDriverEntity> findByDriverAndDelivery(DriverEntity driver, DeliveryEntity delivery);

    @Query(value = "SELECT av FROM AvailableDriverEntity av WHERE av.delivery.entityId = :deliveryId AND av.status = 'OPEN'")
    List<AvailableDriverEntity> findByAvailable(@Param("deliveryId") Long deliveryId);
    @Query(value = "SELECT av.delivery.entityId FROM AvailableDriverEntity av WHERE av.driver.entityId = :driverId AND av.delivery.deliveryStatus = 'OPEN' AND av.status='OPEN'")
    List<Long> findAllProposedUnAssignedDeliveryIdsForDriver(@Param("driverId") Long driverId);
    @Query(value = "SELECT av FROM AvailableDriverEntity av WHERE av.driver.entityId = :driverId AND av.delivery.deliveryStatus = 'OPEN' AND av.status='OPEN' AND av.delivery.entityId=:deliveryId ")
    List<AvailableDriverEntity> checkIfDriverHasOpenProposalForDelivery(@Param("driverId") Long driverId, @Param("deliveryId") Long deliveryId);
    @Query(value = "SELECT count(av) FROM AvailableDriverEntity av WHERE av.driver.entityId = :driverId AND av.delivery.deliveryStatus = 'OPEN' AND av.status='OPEN' ")
    Long getCountOfDriverOpenProposals(@Param("driverId") Long driverId);

    // Update query to decline all open proposals for a delivery except for the selected driver
    @Modifying
    @Transactional
    @Query(value = "UPDATE AvailableDriverEntity av SET av.status = 'DECLINED' WHERE av.delivery.entityId = :deliveryId AND av.driver.entityId != :selectedDriverId AND av.status = 'OPEN'")
    int declineOtherDriverProposalsForDelivery(@Param("deliveryId") Long deliveryId, @Param("selectedDriverId") Long selectedDriverId);

    // Update query to accept the selected driver's proposal
    @Modifying
    @Transactional
    @Query(value = "UPDATE AvailableDriverEntity av SET av.status = 'ACCEPTED' WHERE av.delivery.entityId = :deliveryId AND av.driver.entityId = :selectedDriverId AND av.status = 'OPEN'")
    int acceptDriverProposalForDelivery(@Param("deliveryId") Long deliveryId, @Param("selectedDriverId") Long selectedDriverId);



}
