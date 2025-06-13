package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.internal.CommissionDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.CommissionEntity;
import zw.co.kenac.takeu.backend.repository.CommissionRepository;
import zw.co.kenac.takeu.backend.service.internal.CommissionService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class CommissionServiceImpl implements CommissionService {

    private final CommissionRepository commissionRepository;

    @Override
    @Transactional
    public CommissionEntity createCommission(CommissionDto commissionDto) {
        log.info("Creating new commission with name: {}", commissionDto.getName());
        
        CommissionEntity commission = new CommissionEntity();
        commission.setName(commissionDto.getName());
        commission.setDescription(commissionDto.getDescription());
        commission.setPercentageFromDisplayValue(commissionDto.getPercentageValue());

        boolean isActive = commissionDto.getIsActive() != null && commissionDto.getIsActive();
        commission.setStatus(isActive ? "ACTIVE" : "INACTIVE");


        if (isActive) {
            deactivateAllCommissions();// panoapa we are making sure we have only one active commission charge rule
        }

        CommissionEntity savedCommission = commissionRepository.save(commission);
        log.info("======> Commission created with ID: {}", savedCommission.getEntityId());
        return savedCommission;
    }

    @Override
    @Transactional
    public CommissionEntity updateCommission(Long id, CommissionDto commissionDto) {
        log.info("Updating commission with ID: {}", id);
        
        CommissionEntity commission = commissionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Commission not found with id: " + id));

        commission.setName(commissionDto.getName());
        commission.setDescription(commissionDto.getDescription());
        commission.setPercentageFromDisplayValue(commissionDto.getPercentageValue());

        // Only update status if the isActive flag is explicitly provided
        if (commissionDto.getIsActive() != null) {
            boolean isActive = commissionDto.getIsActive();

            // If setting to active and commission is not already active
            if (isActive && !commission.isActive()) {
                deactivateAllCommissionsExcept(id);
                commission.activate();
                log.info("=====> Commission ID: {} has been activated", id);
            }
            // If setting to inactive and commission is currently active
            else if (!isActive && commission.isActive()) {
                commission.deactivate();
                log.info("=====> Commission ID: {} has been deactivated", id);
            }
        }

        CommissionEntity updatedCommission = commissionRepository.save(commission);
        log.info("=======> Commission updated successfully");
        return updatedCommission;
    }

    @Override
    @Transactional
    public CommissionEntity activateCommission(Long id) {
        log.info("Activating commission with ID: {}", id);
        
        CommissionEntity commission = commissionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Commission not found with id: " + id));

        if (!commission.isActive()) {
            deactivateAllCommissions();
            commission.activate();
            commission = commissionRepository.save(commission);
            log.info("=======> Commission ID: {} has been activated", id);
        } else {
            log.info("========> Commission ID: {} is already active", id);
        }

        return commission;
    }

    @Override
    @Transactional
    public CommissionEntity deactivateCommission(Long id) {
        log.info("=====>Deactivating commission with ID: {}", id);
        
        CommissionEntity commission = commissionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Commission not found with id: " + id));

        if (commission.isActive()) {
            commission.deactivate();
            commission = commissionRepository.save(commission);
            log.info("=======> Commission ID: {} has been deactivated", id);
        } else {
            log.info("=======> Commission ID: {} is already inactive", id);
        }

        return commission;
    }

    @Override
    public List<CommissionEntity> getAllCommissions() {
        log.info("Retrieving all commissions");
        return commissionRepository.findAll();
    }

    @Override
    public Optional<CommissionEntity> getCommissionById(Long id) {
        log.info("=======> Retrieving commission with ID: {}", id);
        return commissionRepository.findById(id);
    }

    @Override
    public Optional<CommissionEntity> getActiveCommission() {
        log.info("Retrieving active commission");
        Optional<CommissionEntity> activeCommission = commissionRepository.findActiveCommission();
        
        if (activeCommission.isPresent()) {
            log.info("Active commission found with ID: {}", activeCommission.get().getEntityId());
        } else {
            log.info("========>No active commission found");
            throw new ResourceNotFoundException("Active commission not found : Active a commission Please " );

        }
        
        return activeCommission;
    }

    @Override
    public BigDecimal calculateCommissionForAmount(BigDecimal amount) {
        if (amount == null) {
            log.warn("=======> Cannot calculate commission for null amount");
            return BigDecimal.ZERO;
        }

        log.info("==========> Calculating commission for amount: {}", amount);
        BigDecimal commission = getActiveCommission()
                .map(activeCommission -> {
                    BigDecimal calculatedAmount = activeCommission.calculateCommission(amount);
                    log.info("========>Commission calculated: {} ({}% of {})",
                            calculatedAmount,
                            activeCommission.getPercentageAsDisplayValue(),
                            amount);
                    return calculatedAmount;
                })
                .orElse(BigDecimal.ZERO);

        if (commission.compareTo(BigDecimal.ZERO) == 0) {
            log.warn("=========>No commission calculated - no active commission found");
        }
        
        return commission;
    }

    /**
     * Helper method to deactivate all commissions
     */
    private void deactivateAllCommissions() {
        log.info("Deactivating all currently active commissions");
        List<CommissionEntity> activeCommissions = commissionRepository.findByStatusIgnoreCase("ACTIVE");
        
        if (!activeCommissions.isEmpty()) {
            log.info(" ======> Found {} active commissions to deactivate", activeCommissions.size());
            activeCommissions.forEach(commission -> {
                commission.deactivate();
                log.debug("======>Commission ID: {} deactivated", commission.getEntityId());
            });
            commissionRepository.saveAll(activeCommissions);
        } else {
            log.info("No active commissions found");
        }
    }

    private void deactivateAllCommissionsExcept(Long id) {
        log.info("===> Deactivating all commissions except ID: {}", id);
        List<CommissionEntity> otherCommissions = commissionRepository.findAllExceptId(id);
        List<CommissionEntity> activeOtherCommissions = otherCommissions.stream()
                .filter(CommissionEntity::isActive)
                .toList();

        if (!activeOtherCommissions.isEmpty()) {
            log.info("===> Found {} other active commissions to deactivate", activeOtherCommissions.size());
            activeOtherCommissions.forEach(commission -> {
                commission.deactivate();
                log.debug("====> Commission ID: {} deactivated", commission.getEntityId());
            });
            commissionRepository.saveAll(activeOtherCommissions);
        } else {
            log.info("=====> No other active commissions found");
        }
    }
}