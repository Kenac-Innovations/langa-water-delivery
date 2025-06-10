package zw.co.kenac.takeu.backend.dto.internal;


import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommissionDto {
    private Long id;
    @NotBlank(message = "Commission name is required")
    private String name;
    private String description;
    @NotNull(message = "Percentage is required")
    @DecimalMin(value = "0.0", inclusive = true, message = "Percentage must be at least 0")
    @DecimalMax(value = "100.0", inclusive = true, message = "Percentage cannot exceed 100")
    private BigDecimal percentageValue; // This will be displayed as 0-100 (e.g., 15 for 15%)
    private String status;
    private Boolean isActive; // Used for toggling active status
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
