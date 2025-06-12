package zw.co.kenac.takeu.backend.service.waterdelivery.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.DropOffLocationRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.ScheduledDetailsRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.WaterDeliveryCreateRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.WaterOrderCreateRequestDto;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntity;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.embedded.DropOffLocation;
import zw.co.kenac.takeu.backend.model.embedded.ScheduledDetails;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.waterdelivery.Promotions;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterOrder;
import zw.co.kenac.takeu.backend.model.enumeration.OrderStatus;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentStatus;
import zw.co.kenac.takeu.backend.repository.*;
import zw.co.kenac.takeu.backend.service.waterdelivery.WaterOrderService;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class WaterOrderServiceImpl implements WaterOrderService {

    private final WaterOrderRepository waterOrderRepository;
    private final WaterDeliveryRepository waterDeliveryRepository;
    private final ClientRepository clientRepository;
    private final PromotionsRepository promotionsRepository;
    private final ClientAddressRepository clientAddressRepository;

    @Override
    public WaterOrderResponse createOrder(WaterOrderCreateRequestDto request) {
        ClientEntity client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + request.getClientId()));

        BigDecimal totalAmount = request.getDeliveries().stream()
                .map(WaterDeliveryCreateRequestDto::getPriceAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        WaterOrder order = new WaterOrder();
        order.setClient(client);
        order.setOrderStatus(OrderStatus.CREATED);
        order.setPaymentStatus(PaymentStatus.PENDING);
        if (request.getPromoCode() != null) {
            Promotions promotions = promotionsRepository.findByPromoCode(request.getPromoCode()).orElse(null);
            if (promotions != null && promotions.getIsActive()) {
                BigDecimal discountAmount = totalAmount.multiply(BigDecimal.valueOf(promotions.getDiscountPercentage()).divide(BigDecimal.valueOf(100)));
                totalAmount = totalAmount.subtract(discountAmount);
            }
        }

        order.setTotalAmount(totalAmount);
        order.setOrderDate(LocalDateTime.now());

        WaterOrder savedOrder = waterOrderRepository.save(order);

        // Create and save deliveries
        List<WaterDelivery> deliveries = request.getDeliveries().stream()
                .map(deliveryRequest -> createDelivery(savedOrder, deliveryRequest))
                .collect(Collectors.toList());

        savedOrder.setDeliveries(deliveries);
        waterOrderRepository.save(savedOrder);

        // Convert to response DTO
        return mapToResponse(savedOrder, deliveries);
    }

    @Override
    public WaterOrderResponse getOrderById(Long orderId) {
        WaterOrder order = waterOrderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with id: " + orderId));
        return mapToResponse(order, order.getDeliveries());
    }

    @Override
    public PaginatedResponse<WaterOrderResponse> getOrdersByClient(Long clientId, String status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equals("ALL")) {
            Page<WaterOrder> deliveries = waterOrderRepository.findByClient(pageable,clientId);
            return paginateResponse(deliveries);
        } else {
            Page<WaterOrder> deliveries = waterOrderRepository.findByClientAndStatus(pageable, clientId,status);
            return paginateResponse(deliveries);
        }


    }



    @Override
    public PaginatedResponse<WaterOrderResponse> getAllOrders(String status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equals("ALL")) {
            Page<WaterOrder> deliveries = waterOrderRepository.findByAll(pageable);
            return paginateResponse(deliveries);
        } else {
            Page<WaterOrder> deliveries = waterOrderRepository.findAllAndStatus(pageable,status);
            return paginateResponse(deliveries);
        }
    }

    private WaterDelivery createDelivery(WaterOrder order, WaterDeliveryCreateRequestDto request) {
        WaterDelivery delivery = new WaterDelivery();
        delivery.setOrder(order);
        delivery.setPriceAmount(request.getPriceAmount());
        delivery.setAutoAssignDriver(request.getAutoAssignDriver());
        delivery.setIsScheduled(request.getIsScheduled());
        delivery.setDeliveryInstructions(request.getDeliveryInstructions());
        delivery.setDeliveryStatus(DeliveryStatus.OPEN.name()); // Default status

        if (request.getDropOffLocation() != null) {
            delivery.setDropOffLocation(mapDropOffLocation(request.getDropOffLocation(), order));
        }

        if (request.getScheduledDetails() != null) {
            delivery.setScheduledDetails(mapScheduledDetails(request.getScheduledDetails()));
        }

        return waterDeliveryRepository.save(delivery);
    }

    private DropOffLocation mapDropOffLocation(DropOffLocationRequestDto dto, WaterOrder order) {
        if (dto == null) return null;
        if (dto.getAddressId() != null) {
            ClientAddressesEntity clientAddresses = clientAddressRepository.findById(dto.getAddressId()).orElse(null);
            if (clientAddresses != null) {
                if (dto.getUseMyContact()) {
                    return DropOffLocation.builder().dropOffAddressType(clientAddresses.getAddressEntered())
                            .dropOffLatitude(clientAddresses.getLatitude())
                            .dropOffLongitude(clientAddresses.getLongitude())
                            .dropOffLocation((clientAddresses.getAddressFormatted()))
                            .dropOffContactName(order.getClient().getFullName())
                            .dropOffContactPhone(order.getClient().getMobileNumber())
                            .build();

                } else {
                    return DropOffLocation.builder().dropOffAddressType(clientAddresses.getAddressEntered())
                            .dropOffLatitude(clientAddresses.getLatitude())
                            .dropOffLongitude(clientAddresses.getLongitude())
                            .dropOffLocation((clientAddresses.getAddressFormatted()))
                            .dropOffContactName(dto.getDropOffContactName())
                            .dropOffContactPhone(dto.getDropOffContactPhone())
                            .build();
                }
            }
        }


        return new DropOffLocation(dto.getDropOffLatitude()
                , dto.getDropOffLongitude()
                , dto.getDropOffLocation()
                , dto.getDropOffAddressTyped()
                , dto.getUseMyContact() != null && dto.getUseMyContact() ? order.getClient().getFullName() : dto.getDropOffContactName()
                , dto.getUseMyContact() != null && dto.getUseMyContact() ? order.getClient().getMobileNumber() : dto.getDropOffContactPhone());
    }

    private ScheduledDetails mapScheduledDetails(ScheduledDetailsRequestDto dto) {
        if (dto == null) return null;
        return new ScheduledDetails(dto.getScheduledDate(), dto.getScheduledTime());
    }
    public PaginatedResponse<WaterOrderResponse> paginateResponse(Page<WaterOrder> page) {
        List<WaterOrder> deliveries = page.getContent();

        List<WaterOrderResponse> driverDeliveryResponses = deliveries.stream()
                .map(x->{
                    return mapToResponse(x,x.getDeliveries());
                })
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(driverDeliveryResponses, pagination);
    }
    private WaterOrderResponse mapToResponse(WaterOrder order, List<WaterDelivery> deliveries) {
        return WaterOrderResponse.builder()
                .orderId(order.getEntityId())
                .clientId(order.getClient().getEntityId())
                .clientName(order.getClient().getFullName())
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
                .priceAmount(delivery.getPriceAmount())
                .autoAssignDriver(delivery.getAutoAssignDriver())
                .dropOffLocation(delivery.getDropOffLocation())
                .isScheduled(delivery.getIsScheduled())
                .deliveryInstructions(delivery.getDeliveryInstructions())
                .scheduledDetails(delivery.getScheduledDetails())
                .status(delivery.getDeliveryStatus())
                .build();
    }
} 