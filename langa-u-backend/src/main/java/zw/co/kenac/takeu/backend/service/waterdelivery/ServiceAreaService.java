package zw.co.kenac.takeu.backend.service.waterdelivery;

import zw.co.kenac.takeu.backend.dto.waterdelivery.request.GeoPoint;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.ServiceAreaRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.ServiceAreaResponse;

import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
public interface ServiceAreaService {

    ServiceAreaResponse createServiceArea(ServiceAreaRequest request);

    ServiceAreaResponse updateServiceArea(Long id, ServiceAreaRequest request);

    ServiceAreaResponse getServiceArea(Long id);

    List<ServiceAreaResponse> getAllServiceAreas();

    List<ServiceAreaResponse> getActiveServiceAreas();

    List<ServiceAreaResponse> findServiceAreasContainingPoint(GeoPoint point);

    boolean isPointInAnyActiveServiceArea(GeoPoint point);

    void deleteServiceArea(Long id);

    void toggleServiceAreaStatus(Long id);

    List<ServiceAreaResponse> searchServiceAreasByName(String name);
}
