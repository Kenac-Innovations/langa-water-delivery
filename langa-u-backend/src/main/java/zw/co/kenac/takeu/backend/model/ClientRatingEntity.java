package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.math.BigDecimal;
import java.util.Set;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sp_client_rating")
public class ClientRatingEntity extends AbstractEntity {

    @Column(precision = 10, scale = 2)
    private BigDecimal rating;
    
    @ElementCollection
    @CollectionTable(name = "client_rating_comments", joinColumns = @JoinColumn(name = "client_rating_id"))
    @Column(columnDefinition = "TEXT")
    private Set<String> comments; // Fixed typo in field name
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id")
    private ClientEntity client;

    @OneToOne
    @JoinColumn(name = "delivery_id", referencedColumnName = "entity_id")
    private DeliveryEntity delivery;

    // Helper method to validate rating
    public void validateRating() {
        if (rating.compareTo(BigDecimal.ZERO) < 0 || rating.compareTo(new BigDecimal("5.0")) > 0) {
            throw new IllegalArgumentException("Rating must be between 0 and 5");
        }
    }
}
