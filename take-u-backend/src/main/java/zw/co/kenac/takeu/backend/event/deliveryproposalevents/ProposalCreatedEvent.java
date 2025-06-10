package zw.co.kenac.takeu.backend.event.deliveryproposalevents;

import lombok.Getter;
import lombok.Setter;
import org.springframework.context.ApplicationEvent;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryProposalDto;

@Getter
@Setter
public class ProposalCreatedEvent extends ApplicationEvent {
    private final DriverDeliveryProposalDto proposal;

    public ProposalCreatedEvent(Object source, DriverDeliveryProposalDto proposal) {
        super(source);
        this.proposal = proposal;
    }
} 