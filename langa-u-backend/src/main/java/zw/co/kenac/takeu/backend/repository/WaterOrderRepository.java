package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterOrder;

import java.util.List;

@Repository
public interface WaterOrderRepository extends JpaRepository<WaterOrder, Long> {
    List<WaterOrder> findByClientEntityId(Long clientId);
} 