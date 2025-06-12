package zw.co.kenac.takeu.backend.service.waterdelivery.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.CreateWaterOrderRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.WaterDeliveryRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterOrder;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.OrderStatus;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentStatus;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.repository.WaterDeliveryRepository;
import zw.co.kenac.takeu.backend.repository.WaterOrderRepository;
import zw.co.kenac.takeu.backend.service.waterdelivery.WaterOrderService;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class WaterOrderServiceImpl implements WaterOrderService {

    private final WaterOrderRepository waterOrderRepository;
    private final WaterDeliveryRepository waterDeliveryRepository;
    private final ClientRepository clientRepository;

    private static final BigDecimal UNIT_PRICE = new BigDecimal("5.00"); // Example unit price

    @Override
    public WaterOrderResponse createOrder(CreateWaterOrderRequest request) {
        // Find client
        ClientEntity client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + request.getClientId()));

        // Create water order
        WaterOrder order = new WaterOrder();
        order.setClient(client);
        order.setDeliveryAddress(request.getDeliveryAddress());
        order.setSpecialInstructions(request.getSpecialInstructions());
        order.setOrderStatus(OrderStatus.CREATED);
        order.setPaymentStatus(PaymentStatus.PENDING);
        order.setOrderDate(LocalDateTime.now());

        // Save order first to get the ID
        order = waterOrderRepository.save(order);

        // Create and save deliveries
        List<WaterDelivery> deliveries = request.getDeliveries().stream()
                .map(deliveryRequest -> createDelivery(order, deliveryRequest))
                .collect(Collectors.toList());

        // Calculate total amount
        BigDecimal totalAmount = deliveries.stream()
                .map(WaterDelivery::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        order.setTotalAmount(totalAmount);
        order = waterOrderRepository.save(order);

        // Convert to response DTO
        return mapToResponse(order, deliveries);
    }

    private WaterDelivery createDelivery(WaterOrder order, WaterDeliveryRequestDto request) {
        WaterDelivery delivery = new WaterDelivery();
        delivery.setOrder(order);
        delivery.setQuantity(request.getQuantity());
        delivery.setDeliveryDate(request.getDeliveryDate());
        delivery.setDeliveryNotes(request.getDeliveryNotes());
        delivery.setStatus(DeliveryStatus.PENDING);
        delivery.setUnitPrice(UNIT_PRICE);
        delivery.setTotalPrice(UNIT_PRICE.multiply(new BigDecimal(request.getQuantity())));

        return waterDeliveryRepository.save(delivery);
    }

    private WaterOrderResponse mapToResponse(WaterOrder order, List<WaterDelivery> deliveries) {
        return WaterOrderResponse.builder()
                .orderId(order.getEntityId())
                .clientId(order.getClient().getEntityId())
                .clientName(order.getClient().getFullName())
                .deliveryAddress(order.getDeliveryAddress())
                .specialInstructions(order.getSpecialInstructions())
                .orderStatus(order.getOrderStatus())
                .paymentStatus(order.getPaymentStatus())
                .totalAmount(order.getTotalAmount())
                .orderDate(order.getOrderDate())
                .deliveries(deliveries.stream()
                        .map(this::mapDeliveryToResponse)
                        .collect(Collectors.toList()))
                .build();
    }

    private WaterDeliveryResponse mapDeliveryToResponse(WaterDelivery delivery) {
        return WaterDeliveryResponse.builder()
                .deliveryId(delivery.getEntityId())
                .quantity(delivery.getQuantity())
                .deliveryDate(delivery.getDeliveryDate())
                .deliveryNotes(delivery.getDeliveryNotes())
                .status(delivery.getStatus())
                .unitPrice(delivery.getUnitPrice())
                .totalPrice(delivery.getTotalPrice())
                .build();
    }
} 