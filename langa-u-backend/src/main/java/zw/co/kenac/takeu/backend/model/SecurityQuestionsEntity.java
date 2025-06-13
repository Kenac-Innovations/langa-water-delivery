package zw.co.kenac.takeu.backend.model;


import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CreationTimestamp;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.time.LocalDateTime;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 11/6/2025
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Table(name = "ms_security_question")
public class SecurityQuestionsEntity  extends AbstractEntity {
    private String question;
    @CreationTimestamp
    private LocalDateTime createdDate;
}
