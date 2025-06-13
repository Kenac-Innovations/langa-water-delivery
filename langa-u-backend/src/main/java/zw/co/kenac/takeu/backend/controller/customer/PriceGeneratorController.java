package zw.co.kenac.takeu.backend.controller.customer;

import io.swagger.v3.oas.annotations.parameters.RequestBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.client.PriceRequest;

import java.math.BigDecimal;

@RequestMapping("${custom.base.path}/client/price-generator")
public interface PriceGeneratorController {

    @PostMapping
    ResponseEntity<GenericResponse<BigDecimal>> generatePrice(@RequestBody PriceRequest request);

}
