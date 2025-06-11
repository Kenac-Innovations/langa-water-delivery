package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "ms_client_security_answer")
public class ClientSecurityAnswerEntity extends AbstractEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", referencedColumnName = "entity_id")
    private ClientEntity client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "security_question_id", referencedColumnName = "entity_id")
    private SecurityQuestionsEntity securityQuestion;

    @Column(nullable = false)
    private String answer;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdDate;
} 