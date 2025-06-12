package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

import java.util.List;

@Repository
public interface WaterDeliveryRepository extends JpaRepository<WaterDelivery, Long> {
    List<WaterDelivery> findByDriverEntityId(Long driverId);
} 