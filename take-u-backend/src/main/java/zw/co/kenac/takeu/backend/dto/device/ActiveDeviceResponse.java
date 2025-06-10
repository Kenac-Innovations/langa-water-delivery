package zw.co.kenac.takeu.backend.dto.device;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActiveDeviceResponse {
    private Long id;
    private String deviceName;
    private String devicePlatform;
    private LocalDateTime lastActiveTime;
    private String pushNotificationToken;
    private Boolean active;
}
