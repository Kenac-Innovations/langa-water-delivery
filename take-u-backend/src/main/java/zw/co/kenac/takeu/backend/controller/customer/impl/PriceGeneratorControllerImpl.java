package zw.co.kenac.takeu.backend.controller.customer.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.customer.PriceGeneratorController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.client.PriceRequest;

import java.math.BigDecimal;

@RestController
@RequiredArgsConstructor
public class PriceGeneratorControllerImpl implements PriceGeneratorController {
    @Override
    public ResponseEntity<GenericResponse<BigDecimal>> generatePrice(PriceRequest request) {
        return ResponseEntity.ok(GenericResponse.success(BigDecimal.TEN));
    }
}
