package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 26/5/2025
 */
@Getter
@Setter
public class DeliveryCompletedEvent extends ApplicationEvent {
    private Long deliveryId;
    private DeliveryStatus deliveryStatus;
    public DeliveryCompletedEvent(Object source,Long deliveryId, DeliveryStatus deliveryStatus) {
        super(source);
        this.deliveryId = deliveryId;
        this.deliveryStatus = deliveryStatus;
    }
}
