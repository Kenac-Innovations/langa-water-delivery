package zw.co.kenac.takeu.backend.repository;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

@Repository
public interface WaterDeliveryRepository extends JpaRepository<WaterDelivery, Long> {
    @Query("SELECT W FROM WaterDelivery W WHERE W.deliveryStatus=:status ")
    Page<WaterDelivery> findByAllByStatus(Pageable pageable, String status);
    @Query("SELECT W FROM WaterDelivery W WHERE W.driver.entityId=:driverId ")
    Page<WaterDelivery> findByDriverEntity(Pageable pageable, Long driverId);

    @Query("SELECT W FROM WaterDelivery W WHERE W.driver.entityId=:driverId AND W.deliveryStatus=:status")
    Page<WaterDelivery> findByDriverEntityAndStatus(Pageable pageable, Long driverId,String status);

    @Query("SELECT W FROM WaterDelivery W WHERE W.order.client.entityId=:clientId")
    Page<WaterDelivery> findByClient(Pageable pageable, Long clientId);

    @Query("SELECT W FROM WaterDelivery W WHERE W.order.client.entityId=:clientId AND W.deliveryStatus=:status")
    Page<WaterDelivery> findByClientAndStatus(Pageable pageable, Long clientId,String status);
} 