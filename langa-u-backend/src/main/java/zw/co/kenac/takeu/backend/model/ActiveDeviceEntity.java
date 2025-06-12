package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.time.LocalDateTime;

@Entity
@Table(name = "active_devices")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActiveDeviceEntity extends AbstractEntity {
    @Column(name = "device_name")
    private String deviceName;
    
    @Column(name = "device_platform")
    private String devicePlatform;
    
    @Column(name = "last_active_time")
    private LocalDateTime lastActiveTime;
    
    @Column(name = "push_notification_token")
    private String pushNotificationToken;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserEntity user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id")//
    private DriverEntity driver;
    
    @Column(name = "active")
    private Boolean active = true;
    
    @PrePersist
    protected void onCreate() {
        lastActiveTime = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        lastActiveTime = LocalDateTime.now();
    }
}
