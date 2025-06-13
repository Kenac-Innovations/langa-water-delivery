package zw.co.kenac.takeu.backend.dto.device;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActiveDeviceRequest {
    private String deviceName;
    private String devicePlatform;
    private String pushNotificationToken;
}
