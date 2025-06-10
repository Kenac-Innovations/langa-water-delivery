package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 24/5/2025
 */
@Getter
@Setter

public class DeliveryCreatedEvent extends ApplicationEvent {

    private DriverDeliveryResponse delivery;
    public DeliveryCreatedEvent(Object source, DriverDeliveryResponse dto) {
        super(source);
        this.delivery = dto;

    }
}
