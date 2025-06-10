package zw.co.kenac.takeu.backend.mailer.dto;

import lombok.*;
import org.checkerframework.checker.units.qual.N;

@Builder

public record EmailGenericDto(String subject, String body, String recipient, String cc ) {
}
