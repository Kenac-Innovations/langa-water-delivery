package zw.co.kenac.takeu.backend.event.deliveryproposalevents;

import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;

@Getter
@Setter
public class ProposalDeletedEvent extends ApplicationEvent {
    private final Long proposalId;
    private final Long deliveryId;

    public ProposalDeletedEvent(Object source, Long proposalId, Long deliveryId) {
        super(source);
        this.proposalId = proposalId;
        this.deliveryId = deliveryId;
    }
} 