package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterOrder;

import java.util.List;

@Repository
public interface WaterOrderRepository extends JpaRepository<WaterOrder, Long> {
//    List<WaterOrder> findByClientEntityId(Long clientId);
    @Query("SELECT W FROM WaterOrder W WHERE W.client.entityId=:clientId")
    Page<WaterOrder> findByClient(Pageable pageable, Long clientId);

    @Query("SELECT W FROM WaterOrder W WHERE W.client.entityId=:clientId AND W.orderStatus=:status")
    Page<WaterOrder> findByClientAndStatus(Pageable pageable, Long clientId,String status);
    @Query("SELECT W FROM WaterOrder W ")
    Page<WaterOrder> findByAll(Pageable pageable);

    @Query("SELECT W FROM WaterOrder W WHERE  W.orderStatus=:status")
    Page<WaterOrder> findAllAndStatus(Pageable pageable, String status);
} 