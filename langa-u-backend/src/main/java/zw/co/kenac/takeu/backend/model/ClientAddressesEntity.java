package zw.co.kenac.takeu.backend.model;


import com.github.davidmoten.geo.GeoHash;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;


import java.time.LocalDateTime;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 10/6/2025
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Table(name = "ms_client_address")
public class ClientAddressesEntity extends AbstractEntity {
    private String title;
    private String addressEntered;
    private double latitude;
    private double longitude;
    private String addressFormatted;
    private String geohash;
    @ManyToOne
    @JoinColumn(name = "client_id", referencedColumnName = "entity_id")
    private ClientEntity client;
    @CreationTimestamp
    private LocalDateTime createdDate;
    @UpdateTimestamp
    private LocalDateTime updatedDate;

    public void setLatitude(double latitude) {
        this.latitude = latitude;
        updateGeohash();
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
        updateGeohash();
    }

    private void updateGeohash() {
        if (latitude != 0 && longitude != 0) {
            this.geohash = GeoHash.encodeHash(latitude, longitude, 9);
        }
    }

}
