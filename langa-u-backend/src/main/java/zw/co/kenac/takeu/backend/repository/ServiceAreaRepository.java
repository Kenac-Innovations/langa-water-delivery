package zw.co.kenac.takeu.backend.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.ServiceArea;

import java.util.List;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@Repository
public interface ServiceAreaRepository extends JpaRepository<ServiceArea, Long> {
    List<ServiceArea> findByActiveTrue();

    List<ServiceArea> findByActiveTrueAndGeohashStartingWith(String geohashPrefix);

    @Query(value = """
        SELECT * FROM service_areas sa 
        WHERE sa.active = true 
        AND (6371 * acos(
            cos(radians(:latitude)) * cos(radians(sa.latitude)) * 
            cos(radians(sa.longitude) - radians(:longitude)) + 
            sin(radians(:latitude)) * sin(radians(sa.latitude))
        )) <= sa.radius_km
        """, nativeQuery = true)
    List<ServiceArea> findActiveServiceAreasContainingPoint(
            @Param("latitude") Double latitude,
            @Param("longitude") Double longitude
    );

    @Query("SELECT sa FROM ServiceArea sa WHERE sa.active = true AND sa.name LIKE %:name%")
    List<ServiceArea> findActiveByNameContaining(@Param("name") String name);
}
