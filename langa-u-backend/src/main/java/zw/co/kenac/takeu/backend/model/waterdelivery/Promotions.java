package zw.co.kenac.takeu.backend.model.waterdelivery;


import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import zw.co.kenac.takeu.backend.model.base.BaseEntity;

import java.time.LocalDate;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Entity
@Table(name = "promotions")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@SuperBuilder
public class Promotions extends BaseEntity {
    private String title;

    private String description;

    private String promoCode;
    private Boolean isActive=false;
    private LocalDate startDate;

    private LocalDate endDate;

    private double discountPercentage;


}