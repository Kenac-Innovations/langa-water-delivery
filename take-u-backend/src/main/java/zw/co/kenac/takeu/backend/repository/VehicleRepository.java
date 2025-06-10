package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.VehicleEntity;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<VehicleEntity, Long> {

    @Query("SELECT v FROM VehicleEntity v WHERE v.driver.entityId = :driverId")
    List<VehicleEntity> findAllByDriverId(Long driverId);

    @Query("SELECT v FROM VehicleEntity v WHERE v.entityId = :vehicleId and  v.driver.entityId = :driverId")
    Optional<VehicleEntity> findByDriverIdAndVehicleId(Long driverId, Long vehicleId);

    @Query("SELECT v FROM VehicleEntity v WHERE v.driver.entityId = :driverId")
    List<VehicleEntity> findByDriverId(@Param("driverId") Long driverId);

    Page<VehicleEntity> findAllByVehicleType(Pageable pageable, String vehicleType);

    Page<VehicleEntity> findAllByDriver(Pageable pageable, DriverEntity driver);


   Optional<VehicleEntity>  findByLicensePlateNo(String licensePlateNo);
}
