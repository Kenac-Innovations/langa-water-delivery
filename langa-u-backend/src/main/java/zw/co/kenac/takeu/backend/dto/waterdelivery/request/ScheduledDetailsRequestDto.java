package zw.co.kenac.takeu.backend.dto.waterdelivery.request;

import lombok.Builder;
import lombok.Value;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * DTO for {@link zw.co.kenac.takeu.backend.model.embedded.ScheduledDetails}
 */
@Value
@Builder
public class ScheduledDetailsRequestDto implements Serializable {
    LocalDate scheduledDate;
    LocalTime scheduledTime;
}