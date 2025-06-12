package zw.co.kenac.takeu.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.CreateWaterOrderRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;
import zw.co.kenac.takeu.backend.service.waterdelivery.WaterOrderService;

import javax.validation.Valid;

@RestController
@RequestMapping("/api/v1/water-orders")
@RequiredArgsConstructor
public class WaterOrderController {

    private final WaterOrderService waterOrderService;

    @PostMapping
    public ResponseEntity<WaterOrderResponse> createOrder(@Valid @RequestBody CreateWaterOrderRequest request) {
        WaterOrderResponse response = waterOrderService.createOrder(request);
        return ResponseEntity.ok(response);
    }
} 