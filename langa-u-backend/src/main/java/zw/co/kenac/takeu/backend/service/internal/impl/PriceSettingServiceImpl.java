package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.model.PriceParamEntity;
import zw.co.kenac.takeu.backend.repository.PriceParamRepository;
import zw.co.kenac.takeu.backend.service.internal.PriceSettingService;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PriceSettingServiceImpl implements PriceSettingService {

    private final PriceParamRepository paramRepository;

    @Override
    public List<PriceParamEntity> findAllPriceParams() {
        return paramRepository.findAll();
    }

    @Override
    public PriceParamEntity findPriceParamById(Long priceId) {
        return null;
    }

    @Override
    public PriceParamEntity createPriceParam(Object priceParam) {
        return null;
    }

    @Override
    public PriceParamEntity updatePriceParam(Long priceId, Object priceParam) {
        return null;
    }

    @Override
    public String deletePriceParam(Long priceId) {
        return "";
    }
}
