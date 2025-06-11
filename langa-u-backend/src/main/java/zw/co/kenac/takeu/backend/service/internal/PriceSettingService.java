package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.model.PriceParamEntity;

import java.util.List;

public interface PriceSettingService {
    List<PriceParamEntity> findAllPriceParams();

    PriceParamEntity findPriceParamById(Long priceId);

    PriceParamEntity createPriceParam(Object priceParam);

    PriceParamEntity updatePriceParam(Long priceId, Object priceParam);

    String deletePriceParam(Long priceId);
}
