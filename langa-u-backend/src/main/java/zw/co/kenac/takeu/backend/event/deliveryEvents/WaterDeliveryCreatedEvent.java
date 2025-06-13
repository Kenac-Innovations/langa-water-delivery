package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 24/5/2025
 */
@Getter
@Setter
public class WaterDeliveryCreatedEvent extends ApplicationEvent {

    private WaterDelivery delivery;

    public WaterDeliveryCreatedEvent(Object source, WaterDelivery dto) {
        super(source);
        this.delivery = dto;

    }
}
