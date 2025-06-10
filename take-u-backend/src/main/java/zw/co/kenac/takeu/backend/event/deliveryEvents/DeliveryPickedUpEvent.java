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
public class DeliveryPickedUpEvent extends ApplicationEvent {
    private Long deliveryId;
    private DeliveryStatus deliveryStatus;
    public DeliveryPickedUpEvent(Object source, Long driverId, DeliveryStatus deliveryStatus) {
        super(source);
        this.deliveryId = driverId;
        this.deliveryStatus = deliveryStatus;

    }
    // update firebase , push notification , sms sending of otps
}
