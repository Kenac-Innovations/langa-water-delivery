package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.Promotions;

import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Repository
public interface PromotionsRepository extends JpaRepository<Promotions, Long> {
    Optional<Promotions> findByPromoCode(String promoCode);
}