package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.ActiveDeviceEntity;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.UserEntity;

import java.util.List;
import java.util.Optional;



@Repository
public interface ActiveDeviceRepository extends JpaRepository<ActiveDeviceEntity, Long> {
    
    List<ActiveDeviceEntity> findByUserAndActiveTrue(UserEntity user);
    
    List<ActiveDeviceEntity> findByDriverAndActiveTrue(DriverEntity driver);
    @Query("SELECT a FROM ActiveDeviceEntity a WHERE a.driver.entityId = :driverId AND a.pushNotificationToken = :token AND a.devicePlatform = :platform AND a.active = true")
    List<ActiveDeviceEntity> findAllByTokenAndDriverIdAndPlatformAndActiveTrue(
            @Param("token") String pushNotificationToken,
            @Param("driverId") Long driverId,
            @Param("platform") String devicePlatform
    );
    @Query("SELECT a FROM ActiveDeviceEntity a WHERE a.user.entityId = :userId AND a.pushNotificationToken = :token AND a.devicePlatform = :platform AND a.active = true")
    List<ActiveDeviceEntity> findAllByTokenAndUserIdAndPlatformAndActiveTrue(
            @Param("token") String pushNotificationToken,
            @Param("userId") Long userId,
            @Param("platform") String devicePlatform
    );
    @Query("SELECT a FROM ActiveDeviceEntity a WHERE a.pushNotificationToken = :token AND a.active = true")
    Optional<ActiveDeviceEntity> findByPushNotificationTokenAndActiveTrue(@Param("token") String token);
    
    @Query("SELECT a FROM ActiveDeviceEntity a WHERE a.user.entityId = :userId AND a.pushNotificationToken = :token AND a.active = true")
    Optional<ActiveDeviceEntity> findByTokenAndUserIdAndActiveTrue(@Param("token") String token, @Param("userId") Long userId);
    
    @Query("SELECT a FROM ActiveDeviceEntity a WHERE a.driver.entityId = :driverId AND a.pushNotificationToken = :token AND a.active = true")
    Optional<ActiveDeviceEntity> findByTokenAndDriverIdAndActiveTrue(@Param("token") String token, @Param("driverId") Long driverId);
}
