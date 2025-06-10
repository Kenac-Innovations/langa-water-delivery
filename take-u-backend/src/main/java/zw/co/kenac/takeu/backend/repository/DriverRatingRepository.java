package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.DriverRatingEntity;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@Repository
public interface DriverRatingRepository extends JpaRepository<DriverRatingEntity, Long> {
    @Query("SELECT dr FROM DriverRatingEntity dr WHERE dr.driver.entityId = :driverId")
    List<DriverRatingEntity> findAllByDriverId(Long driverId);

    @Query("SELECT AVG(dr.rating) FROM DriverRatingEntity dr WHERE dr.driver.entityId = :driverId")
    Optional<BigDecimal> findAverageRatingByDriverIdOptional(Long driverId);
}
