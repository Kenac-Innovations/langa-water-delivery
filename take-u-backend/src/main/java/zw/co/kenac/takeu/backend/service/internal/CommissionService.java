package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.internal.CommissionDto;
import zw.co.kenac.takeu.backend.model.CommissionEntity;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
public interface CommissionService {

    /**
     * Create a new commission
     * @param commissionDto The commission data
     * @return The created commission entity
     */
    CommissionEntity createCommission(CommissionDto commissionDto);

    /**
     * Update an existing commission
     * @param id The ID of the commission to update
     * @param commissionDto The updated commission data
     * @return The updated commission entity
     */
    CommissionEntity updateCommission(Long id, CommissionDto commissionDto);

    /**
     * Activate a commission (and deactivate any other active commission)
     * @param id The ID of the commission to activate
     * @return The activated commission entity
     */
    CommissionEntity activateCommission(Long id);

    /**
     * Deactivate a commission
     * @param id The ID of the commission to deactivate
     * @return The deactivated commission entity
     */
    CommissionEntity deactivateCommission(Long id);

    /**
     * Get all commissions
     * @return List of all commission entities
     */
    List<CommissionEntity> getAllCommissions();

    /**
     * Get a commission by ID
     * @param id The ID of the commission to retrieve
     * @return Optional containing the commission if found
     */
    Optional<CommissionEntity> getCommissionById(Long id);

    /**
     * Get the currently active commission
     * @return Optional containing the active commission if any
     */
    Optional<CommissionEntity> getActiveCommission();

    /**
     * Calculate commission for a given amount using the active commission
     * @param amount The amount to calculate commission on
     * @return The calculated commission amount
     */
    BigDecimal calculateCommissionForAmount(BigDecimal amount);
}
