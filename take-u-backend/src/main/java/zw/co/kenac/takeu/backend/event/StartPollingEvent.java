package zw.co.kenac.takeu.backend.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;
/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 21/5/2025
 */
@Getter
public class StartPollingEvent extends ApplicationEvent {
    private final String pollUrl;
    private final boolean isWebBased;

    public StartPollingEvent(Object source, String pollUrl, boolean isWebBased) {
        super(source);
        this.pollUrl = pollUrl;
        this.isWebBased = isWebBased;
    }
} 