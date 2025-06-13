package zw.co.kenac.takeu.backend.service.driver;


import zw.co.kenac.takeu.backend.dto.waterdelivery.request.DriverWaterDeliveryCompleteRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
public interface DriverWaterDeliveryService {
    public WaterDeliveryResponse acceptDelivery(Long driverId, Long waterDeliveryId);
    public WaterDeliveryResponse completeDelivery(DriverWaterDeliveryCompleteRequest id);
    public WaterDeliveryResponse cancelDelivery(Long driverId, Long waterDeliveryId);
    public WaterDeliveryResponse startDelivery(Long waterDeliveryId);
}
