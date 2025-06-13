package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SecurityAnswerDto {
    private Long questionId;
    private String answer;
} 