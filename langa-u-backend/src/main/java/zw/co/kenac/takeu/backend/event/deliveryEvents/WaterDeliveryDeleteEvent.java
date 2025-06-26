package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 24/5/2025
 */
@Getter
@Setter
public class WaterDeliveryDeleteEvent extends ApplicationEvent {
    private Long id;
    public WaterDeliveryDeleteEvent(Object source, Long id) {
        super(source);
        this.id = id;

    }
}
