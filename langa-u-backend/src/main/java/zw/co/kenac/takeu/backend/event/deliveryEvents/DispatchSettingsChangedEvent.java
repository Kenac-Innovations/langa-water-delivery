package zw.co.kenac.takeu.backend.event.deliveryEvents;


import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
@Getter
@Setter
public class DispatchSettingsChangedEvent extends ApplicationEvent {

    private Boolean status;
    public DispatchSettingsChangedEvent(Object source, Boolean status) {
        super(source);
        this.status = status;


    }
}
