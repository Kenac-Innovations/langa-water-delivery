package zw.co.kenac.takeu.backend.model.embedded;


import jakarta.persistence.Embeddable;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Getter
@Setter
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduledDetails {
    private LocalDate scheduledDate;
    private LocalTime scheduledTime;
}
