package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.ClientRatingEntity;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ClientRatingRepository extends JpaRepository<ClientRatingEntity, Long> {

    @Query("SELECT cr FROM ClientRatingEntity cr WHERE cr.client.entityId = :clientId")
    List<ClientRatingEntity> findAllByClientId(Long clientId);

    @Query("SELECT AVG(cr.rating)  FROM ClientRatingEntity cr where cr.client.entityId = :clientId ")
    Optional<BigDecimal> findClientAverageRating(Long clientId);

}
