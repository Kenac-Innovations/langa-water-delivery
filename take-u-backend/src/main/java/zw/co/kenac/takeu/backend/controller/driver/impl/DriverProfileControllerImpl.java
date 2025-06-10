package zw.co.kenac.takeu.backend.controller.driver.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.driver.DriverProfileController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;

import zw.co.kenac.takeu.backend.service.driver.DriverProfileService;
import zw.co.kenac.takeu.backend.service.internal.DocumentService;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class DriverProfileControllerImpl implements DriverProfileController {

    private final DriverProfileService profileService;

    @Autowired
    private DocumentService documentService;

    @Override
    public ResponseEntity<GenericResponse<DriverProfile>> findDriverProfile(Long driverId) {
        return ResponseEntity.ok(success(profileService.findDriverProfile(driverId)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverProfile>> updateDriverProfile(Long driverId) {
        return ResponseEntity.ok(success(profileService.updateDriverProfile(driverId)));
    }


    @Override
    public ResponseEntity<GenericResponse<String>> updateAvailabilityStatus(Long driverId, Boolean status) {
        return ResponseEntity.ok(success(profileService.updateDriverAvailability(driverId,status)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverProfile>> updateOnlineStatus(Long driverId, Boolean status) {
        return ResponseEntity.ok(success(profileService.updateOnlineStatus(driverId, status)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverProfile>> updateSearchRadius(Long driverId, Double radius) {
        return ResponseEntity.ok(success(profileService.updateDeliverySearchRadius(driverId, radius)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteAccount(Long driverId) {
        return ResponseEntity.ok(success(profileService.deleteAccount(driverId)));
    }

    @Override
    public ResponseEntity<InputStreamResource> downloadDocument(String bucketType, String filename) {
        try {
            InputStream stream = documentService.getDocument(bucketType, filename);
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename);

            return ResponseEntity.ok()
                    .headers(headers)
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(new InputStreamResource(stream));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Override
    public ResponseEntity<Map<String, String>> getDocumentUrl(
           String bucketType,
            String filename,
             Integer expirySeconds) {
        try {
            String url = documentService.getDocumentUrl(bucketType, filename, expirySeconds);
            Map<String, String> response = new HashMap<>();
            response.put("url", url);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }

    @Override
    public ResponseEntity<Void> deleteDocument(
            String bucketType,
            String filename) {
        try {
            documentService.deleteDocument(bucketType, filename);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }


}
