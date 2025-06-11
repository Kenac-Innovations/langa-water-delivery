package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "ms_password_reset_token")
public class PasswordResetToken extends AbstractEntity {

    @Column(nullable = false, unique = true)
    private String token;
    
    @Column(nullable = false)
    private LocalDateTime expiryDate;
    
    @Column(nullable = false)
    private Boolean used = Boolean.FALSE;
    
    @CreationTimestamp
    private LocalDateTime createTime;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", referencedColumnName = "entity_id", nullable = false)
    private UserEntity user;

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiryDate);
    }
    public boolean isValid() {
        return !isExpired() && !used;
    }
}
