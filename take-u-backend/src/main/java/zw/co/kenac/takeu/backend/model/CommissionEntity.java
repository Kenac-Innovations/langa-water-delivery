package zw.co.kenac.takeu.backend.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "st_commission")
public class CommissionEntity extends AbstractEntity {
    private String name;
    private String description;

    // Store percentage as decimal (e.g., 0.15 for 15%)
    @Column(precision = 10, scale = 4)
    private BigDecimal percentage;

    @Column(name = "status")
    private String status; // ACTIVE or INACTIVE

    @CreationTimestamp
    private LocalDateTime createTime;

    @UpdateTimestamp
    private LocalDateTime updateTime;

    /**
     * Calculate commission amount based on the provided amount
     * @param amount The amount to calculate commission on
     * @return The calculated commission amount
     */
    public BigDecimal calculateCommission(BigDecimal amount) {
        if (amount == null || percentage == null) {
            return BigDecimal.ZERO;
        }
        return amount.multiply(percentage).setScale(2, RoundingMode.HALF_UP);
    }
    
    /**
     * Convert display percentage (0-100) to internal decimal representation (0.0-1.0)
     * @param displayPercentage The percentage value as displayed to users (0-100)
     */
    public void setPercentageFromDisplayValue(BigDecimal displayPercentage) {
        if (displayPercentage != null) {
            this.percentage = displayPercentage.divide(new BigDecimal("100"), 4, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * Get the percentage as a display value (0-100)
     * @return The percentage as a display value
     */
    public BigDecimal getPercentageAsDisplayValue() {
        if (percentage == null) {
            return BigDecimal.ZERO;
        }
        return percentage.multiply(new BigDecimal("100")).setScale(2, RoundingMode.HALF_UP);
    }
    
    /**
     * Check if this commission is active
     * @return true if commission is active, false otherwise
     */
    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(status);
    }
    
    /**
     * Activate this commission
     */
    public void activate() {
        this.status = "ACTIVE";
    }
    
    /**
     * Deactivate this commission
     */
    public void deactivate() {
        this.status = "INACTIVE";
    }
}
