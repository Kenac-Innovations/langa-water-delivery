package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 22/4/2025
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sp_cancel")
public class CancelEntity extends AbstractEntity {
    private LocalDateTime timestamp;
    private Long latitude;
    private Long longitude;
    private String reasonCancelling;
}
