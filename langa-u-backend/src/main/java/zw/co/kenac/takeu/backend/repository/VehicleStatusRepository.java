package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.VehicleStatusEntity;

import java.util.Optional;

@Repository
public interface VehicleStatusRepository extends JpaRepository<VehicleStatusEntity, Long> {
    Optional<VehicleStatusEntity> findByStatusName(String name);
}
