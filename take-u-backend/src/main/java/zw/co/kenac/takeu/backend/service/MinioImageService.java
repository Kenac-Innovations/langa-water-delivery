package zw.co.kenac.takeu.backend.service;

import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.errors.MinioException;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Service for generating network image URLs from MinIO storage
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MinioImageService {

    @Qualifier("secondaryMinioClient")
    private final MinioClient minioClient;
    private final Map<String, String> minioBuckets;
    @Value("${minio.buckets.vehicle-documents}")
    private String vehicleDocumentsBucket;
    @Value("${minio.buckets.national-id-images}")
    private String nationalIdImagesBucket;
    @Value("${minio.buckets.drivers-license-images}")
    private String driversLicenseImagesBucket;
    @Value("${minio.buckets.profile-photos}")
    private String profilePhotosBucket;
    @Value("${minio.endpoint}")
    private String minioEndpoint;

    public String generateNetworkImageUrl(String objectName, String bucketKey) {
        if (objectName == null || objectName.isEmpty()) {
            return null;
        }

        String bucketName = minioBuckets.get(bucketKey);
        if (bucketName == null) {
            log.error("Bucket not found for key: {}", bucketKey);
            return null;
        }

        try {
//            return minioClient.getPresignedObjectUrl(
//                    GetPresignedObjectUrlArgs.builder()
//                            .method(Method.GET)
//                            .bucket(bucketName)
//                            .object(objectName)
//                            .expiry(24, TimeUnit.HOURS)
//                            .build());

//                    TODO remove this when domain is availed
            String presignedUrl = minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(bucketName)
                            .object(objectName)
                            .expiry(24, TimeUnit.HOURS)
                            .build());

            // Replace 'localhost:9000' with your public URL
            URI uri = new URI(presignedUrl);
            String externalHost = "10.10.0.112"; // or your public IP / domain
            int port = 9000; // usually no port if using standard https

            URI externalUri = new URI(
                    uri.getScheme(),
                    null,
                    externalHost,
                    port,
                    uri.getPath(),
                    uri.getQuery(),
                    null
            );

            return externalUri.toString();
        } catch (Exception e) {
            log.error("Error generating presigned URL for object: {} in bucket: {}", objectName, bucketName, e);
            return null;
        }
    }

    public String generateProfilePhotoUrl(String objectName) {
        return generateNetworkImageUrl(objectName, profilePhotosBucket);
    }

    public String generateNationalIdImageUrl(String objectName) {
        return generateNetworkImageUrl(objectName, nationalIdImagesBucket);
    }
    

    public String generateDriversLicenseUrl(String objectName) {
        return generateNetworkImageUrl(objectName, driversLicenseImagesBucket);
    }
    public String generateVehicleDocumentsUrl(String objectName) {
        return generateNetworkImageUrl(objectName,vehicleDocumentsBucket );
    }
}
