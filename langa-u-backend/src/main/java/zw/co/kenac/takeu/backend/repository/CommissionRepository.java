package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.CommissionEntity;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 5/15/2025
 */
@Repository
public interface CommissionRepository extends JpaRepository<CommissionEntity, Long> {
    
    /**
     * Find all commissions with the given status (case insensitive)
     * @param status The status to search for
     * @return List of commission entities with matching status
     */
    List<CommissionEntity> findByStatusIgnoreCase(String status);
    
    /**
     * Find the currently active commission
     * @return Optional containing the active commission if it exists
     */
    @Query("SELECT c FROM CommissionEntity c WHERE UPPER(c.status) = 'ACTIVE'")
    Optional<CommissionEntity> findActiveCommission();
    
    /**
     * Find all commissions except the one with the specified ID
     * @param id The ID to exclude
     * @return List of commission entities excluding the one with the given ID
     */
    @Query("SELECT c FROM CommissionEntity c WHERE c.id != :id")
    List<CommissionEntity> findAllExceptId(@Param("id") Long id);
} 