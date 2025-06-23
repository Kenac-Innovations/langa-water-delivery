package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.model.AvailableDriverEntity;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 25/5/2025
 */
@Getter
@Setter
public class WaterDriverAcceptedEvent extends ApplicationEvent {
        private WaterDelivery delivery;
        private Long deliveryId;

    public WaterDriverAcceptedEvent(Object source) {
        super(source);
    }
    public WaterDriverAcceptedEvent(Object source, WaterDelivery delivery) {
        super(source);
        this.delivery = delivery;
    }
    public WaterDriverAcceptedEvent(Object source, Long deliveryId) {
        super(source);
        this.deliveryId = deliveryId;
    }


}
