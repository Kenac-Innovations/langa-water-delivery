package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.*;
import org.springframework.context.ApplicationEvent;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 24/5/2025
 */
@Getter
@Setter

public class DeliveryDeleteEvent extends ApplicationEvent {
    private Long id;
    private String vehicleType;
    public DeliveryDeleteEvent(Object source, Long id,String vehicleType) {
        super(source);
        this.id = id;
        this.vehicleType = vehicleType;

    }
}
