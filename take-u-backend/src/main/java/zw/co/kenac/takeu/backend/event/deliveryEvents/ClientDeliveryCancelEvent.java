package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 26/5/2025
 */
@Getter
@Setter
public class ClientDeliveryCancelEvent extends ApplicationEvent {
    private Long deliveryId;
    private DeliveryEntity delivery;
    private DeliveryStatus currentStatus;
    public ClientDeliveryCancelEvent(Object source, Long deliveryId, DeliveryEntity delivery) {
        super(source);
        this.deliveryId = deliveryId;
        this.delivery = delivery;
    }
    public ClientDeliveryCancelEvent(Object source, Long deliveryId, DeliveryEntity delivery, DeliveryStatus currentStatus) {
        super(source);
        this.deliveryId = deliveryId;

        this.delivery = delivery;
        this.currentStatus = currentStatus;
    }
}
