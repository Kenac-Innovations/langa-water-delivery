package zw.co.kenac.takeu.backend.service.waterdelivery.impl;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.model.waterdelivery.Promotions;
import zw.co.kenac.takeu.backend.repository.PromotionsRepository;
import zw.co.kenac.takeu.backend.service.waterdelivery.PromotionsService;

import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PromotionsServiceImpl implements PromotionsService {


    private final PromotionsRepository promotionsRepository;


//    @Override
//    public Promotions createPromotion(Promotions promotion) {
//        return null;
//    }
    @Override
    public Promotions createPromotion(Promotions promotion) {
        return promotionsRepository.save(promotion);
    }

    @Override
    public List<Promotions> getAllPromotions() {
        return promotionsRepository.findAll();
    }

    @Override
    public Promotions getPromotionById(Long id) {
        return promotionsRepository.findById(id).orElse(null);
    }

    @Override
    public Promotions updatePromotion(Long id, Promotions updatedPromotion) {
        return promotionsRepository.findById(id).map(promotion -> {
            promotion.setTitle(updatedPromotion.getTitle());
            promotion.setDescription(updatedPromotion.getDescription());
            promotion.setPromoCode(updatedPromotion.getPromoCode());
            promotion.setStartDate(updatedPromotion.getStartDate());
            promotion.setEndDate(updatedPromotion.getEndDate());
            promotion.setDiscountPercentage(updatedPromotion.getDiscountPercentage());
            return promotionsRepository.save(promotion);
        }).orElseThrow(() -> new RuntimeException("Promotion not found with id: " + id));
    }

    @Override
    public void deletePromotion(Long id) {
        promotionsRepository.deleteById(id);
    }
}