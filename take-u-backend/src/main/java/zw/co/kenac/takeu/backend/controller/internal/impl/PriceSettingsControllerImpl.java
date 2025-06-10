package zw.co.kenac.takeu.backend.controller.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.internal.PriceSettingsController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.PriceParamEntity;
import zw.co.kenac.takeu.backend.service.internal.PriceSettingService;

import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class PriceSettingsControllerImpl implements PriceSettingsController {

    private final PriceSettingService priceParamService;

    @Override
    public ResponseEntity<GenericResponse<List<PriceParamEntity>>> findAllPriceSettings() {
        return ResponseEntity.ok(success(priceParamService.findAllPriceParams()));
    }

    @Override
    public ResponseEntity<GenericResponse<PriceParamEntity>> findPriceSettingsById(Long priceId) {
        return ResponseEntity.ok(success(priceParamService.findPriceParamById(priceId)));
    }

    @Override
    public ResponseEntity<GenericResponse<PriceParamEntity>> createPriceParam(Object priceParam) {
        return ResponseEntity.status(201).body(success(priceParamService.createPriceParam(priceParam)));
    }

    @Override
    public ResponseEntity<GenericResponse<PriceParamEntity>> updatePriceParam(Long priceId, Object priceParam) {
        return ResponseEntity.ok(success(priceParamService.updatePriceParam(priceId, priceParam)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deletePriceParam(Long priceId) {
        return ResponseEntity.ok(success(priceParamService.deletePriceParam(priceId)));
    }
}
