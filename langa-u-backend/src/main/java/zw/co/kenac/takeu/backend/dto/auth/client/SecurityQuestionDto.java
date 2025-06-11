package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SecurityQuestionDto {
    private Long id;
    private String question;
} 