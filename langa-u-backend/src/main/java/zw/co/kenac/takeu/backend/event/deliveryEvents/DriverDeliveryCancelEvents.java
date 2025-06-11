package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 26/5/2025
 */
@Getter
@Setter
public class DriverDeliveryCancelEvents extends ApplicationEvent {
    private Long deliveryId;
    public DriverDeliveryCancelEvents(Object source, Long deliveryId) {
        super(source);
        this.deliveryId = deliveryId;
    }
}
