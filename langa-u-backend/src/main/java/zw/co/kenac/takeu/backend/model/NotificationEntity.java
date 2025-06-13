package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.time.LocalDateTime;


@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "notifications")
public class NotificationEntity extends AbstractEntity {
    
    private String title;
    private String message;
    private boolean read;
    
    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName = "entity_id")
    private UserEntity user;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String notificationType;
    
    // Optional: Reference to related entity (e.g., order, ride, etc.)
    private Long referenceId;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
