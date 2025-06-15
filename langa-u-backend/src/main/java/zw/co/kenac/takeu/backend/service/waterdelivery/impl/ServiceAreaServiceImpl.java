package zw.co.kenac.takeu.backend.service.waterdelivery.impl;


import com.github.davidmoten.geo.GeoHash;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.GeoPoint;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.ServiceAreaRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.ServiceAreaResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.waterdelivery.ServiceArea;
import zw.co.kenac.takeu.backend.repository.ServiceAreaRepository;
import zw.co.kenac.takeu.backend.service.waterdelivery.ServiceAreaService;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ServiceAreaServiceImpl implements ServiceAreaService {

    private final ServiceAreaRepository serviceAreaRepository;
    //private final

    @Override
    public ServiceAreaResponse createServiceArea(ServiceAreaRequest request) {
        log.info("Creating service area: {}", request.getName());

        ServiceArea serviceArea = new ServiceArea();
        serviceArea.setName(request.getName());
        serviceArea.setLatitude(request.getLatitude());
        serviceArea.setLongitude(request.getLongitude());
        serviceArea.setRadiusKm(request.getRadiusKm());
        serviceArea.setActive(request.getActive());
        serviceArea.setDescription(request.getDescription());

        serviceArea.setGeohash(GeoHash.encodeHash(request.getLatitude(), request.getLongitude(),9));

        ServiceArea saved = serviceAreaRepository.save(serviceArea);
        log.info("Service area created with ID: {}", saved.getEntityId());

        return mapToResponse(saved);
    }

    @Override
    public ServiceAreaResponse updateServiceArea(Long id, ServiceAreaRequest request) {
        log.info("Updating service area with ID: {}", id);

        ServiceArea serviceArea = serviceAreaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Service area not found with ID: " + id));

        serviceArea.setName(request.getName());
        serviceArea.setLatitude(request.getLatitude());
        serviceArea.setLongitude(request.getLongitude());
        serviceArea.setRadiusKm(request.getRadiusKm());
        serviceArea.setActive(request.getActive());
        serviceArea.setDescription(request.getDescription());
        serviceArea.setGeohash(GeoHash.encodeHash(request.getLatitude(), request.getLongitude(),9));


        ServiceArea updated = serviceAreaRepository.save(serviceArea);
        log.info("Service area updated: {}", updated.getEntityId());

        return mapToResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public ServiceAreaResponse getServiceArea(Long id) {
        return serviceAreaRepository.findById(id)
                .map(this::mapToResponse).orElseThrow(()-> new  ResourceNotFoundException("Service area not fount "));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServiceAreaResponse> getAllServiceAreas() {
        return serviceAreaRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServiceAreaResponse> getActiveServiceAreas() {
        return serviceAreaRepository.findByActiveTrue().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServiceAreaResponse> findServiceAreasContainingPoint(GeoPoint point) {
        log.info("Finding service areas containing point: lat={}, lon={}",
                point.getLatitude(), point.getLongitude());

        List<ServiceArea> serviceAreas = serviceAreaRepository
                .findActiveServiceAreasContainingPoint(point.getLatitude(), point.getLongitude());

        log.info("Found {} service areas containing the point", serviceAreas.size());

        return serviceAreas.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isPointInAnyActiveServiceArea(GeoPoint point) {
        log.info("Checking if point is in any active service area: lat={}, lon={}",
                point.getLatitude(), point.getLongitude());

        List<ServiceArea> serviceAreas = serviceAreaRepository
                .findActiveServiceAreasContainingPoint(point.getLatitude(), point.getLongitude());

        boolean isInServiceArea = !serviceAreas.isEmpty();
        log.info("Point is {} any active service area", isInServiceArea ? "within" : "not within");

        return isInServiceArea;
    }

    @Override
    public void deleteServiceArea(Long id) {
        log.info("Deleting service area with ID: {}", id);

        if (!serviceAreaRepository.existsById(id)) {
            throw new RuntimeException("Service area not found with ID: " + id);
        }

        serviceAreaRepository.deleteById(id);
        log.info("Service area deleted: {}", id);
    }

    @Override
    public void toggleServiceAreaStatus(Long id) {
        log.info("Toggling status for service area with ID: {}", id);

        ServiceArea serviceArea = serviceAreaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Service area not found with ID: " + id));

        serviceArea.setActive(!serviceArea.getActive());
        serviceAreaRepository.save(serviceArea);

        log.info("Service area status toggled to: {}", serviceArea.getActive());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServiceAreaResponse> searchServiceAreasByName(String name) {
        return serviceAreaRepository.findActiveByNameContaining(name).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private ServiceAreaResponse mapToResponse(ServiceArea serviceArea) {
        return new ServiceAreaResponse(
                serviceArea.getEntityId(),
                serviceArea.getName(),
                serviceArea.getLatitude(),
                serviceArea.getLongitude(),
                serviceArea.getRadiusKm(),
                serviceArea.getGeohash(),
                serviceArea.getActive(),
                serviceArea.getDescription()

        );
    }
}
