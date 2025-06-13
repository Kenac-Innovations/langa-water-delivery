package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 26/5/2025
 */
@Getter
@Setter
public class WaterDeliveryCompletedEvent extends ApplicationEvent {
    private Long deliveryId;
    private WaterDelivery delivery;
    public WaterDeliveryCompletedEvent(Object source, Long deliveryId, WaterDelivery delivery) {
        super(source);
        this.deliveryId = deliveryId;
        this.delivery = delivery;
    }
    public WaterDeliveryCompletedEvent(Object source,  WaterDelivery delivery) {
        super(source);
        this.delivery = delivery;
    }
}
