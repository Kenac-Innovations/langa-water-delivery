package zw.co.kenac.takeu.backend.model.waterdelivery;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import zw.co.kenac.takeu.backend.model.base.BaseEntity;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@Entity
@Table(name = "service_areas")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor

public class ServiceArea extends BaseEntity {

    @NotNull
    @Column(nullable = false)
    private String name;

    @NotNull
    @Column(nullable = false)
    private Double latitude;

    @NotNull
    @Column(nullable = false)
    private Double longitude;

    @NotNull
    @Positive
    @Column(nullable = false)
    private Double radiusKm;

    @Column(length = 12)
    private String geohash;

    @NotNull
    @Column(nullable = false)
    private Boolean active = true;

    @Column(length = 500)
    private String description;

}
