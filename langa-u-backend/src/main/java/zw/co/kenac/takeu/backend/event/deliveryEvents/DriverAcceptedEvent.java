package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.model.AvailableDriverEntity;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 25/5/2025
 */
@Getter
@Setter
public class DriverAcceptedEvent extends ApplicationEvent {
        private AvailableDriverEntity availableDriver;
    public DriverAcceptedEvent(Object source) {
        super(source);
    }
    public DriverAcceptedEvent(Object source, AvailableDriverEntity availableDriver) {
        super(source);
        this.availableDriver = availableDriver;
    }
}
