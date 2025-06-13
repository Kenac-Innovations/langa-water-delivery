package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.Data;
import java.util.List;

@Data
public class SecurityChallengeRequest {
    private String email;
    private List<SecurityAnswerDto> answers;
} 