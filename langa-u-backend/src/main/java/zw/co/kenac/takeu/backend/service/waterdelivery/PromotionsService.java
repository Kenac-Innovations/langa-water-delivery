package zw.co.kenac.takeu.backend.service.waterdelivery;

import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.model.waterdelivery.Promotions;

import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */

public interface PromotionsService {
    Promotions createPromotion(Promotions promotion);
    List<Promotions> getAllPromotions();
    Promotions getPromotionById(Long id);
    Promotions updatePromotion(Long id, Promotions promotion);
    void deletePromotion(Long id);
}