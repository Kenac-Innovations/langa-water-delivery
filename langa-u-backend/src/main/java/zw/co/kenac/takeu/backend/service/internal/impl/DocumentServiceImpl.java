package zw.co.kenac.takeu.backend.service.internal.impl;

import io.minio.*;
import io.minio.http.Method;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import zw.co.kenac.takeu.backend.config.MinioConfig;
import zw.co.kenac.takeu.backend.service.internal.DocumentService;

import java.io.InputStream;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
public class DocumentServiceImpl implements DocumentService {

    @Autowired
    private MinioClient minioClient;

    @Autowired
    private MinioConfig.MinioProperties minioProperties;  // Use the MinioProperties class

    @Override
    public String uploadDocument(String bucketType, MultipartFile file) throws Exception {
        Map<String, String> buckets = minioProperties.getBuckets();  // Get buckets from properties

        if (!buckets.containsKey(bucketType)) {
            throw new IllegalArgumentException("Invalid bucket type: " + bucketType);
        }

        String bucketName = buckets.get(bucketType);
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String filename = UUID.randomUUID().toString() + extension;

        minioClient.putObject(
                PutObjectArgs.builder()
                        .bucket(bucketName)
                        .object(filename)
                        .stream(file.getInputStream(), file.getSize(), -1)
                        .contentType(file.getContentType())
                        .build());

        return filename;
    }

    @Override
    public InputStream getDocument(String bucketType, String filename) throws Exception {
        Map<String, String> buckets = minioProperties.getBuckets();

        if (!buckets.containsKey(bucketType)) {
            throw new IllegalArgumentException("Invalid bucket type: " + bucketType);
        }

        String bucketName = buckets.get(bucketType);

        return minioClient.getObject(
                GetObjectArgs.builder()
                        .bucket(bucketName)
                        .object(filename)
                        .build());
    }

    @Override
    public void deleteDocument(String bucketType, String filename) throws Exception {
        Map<String, String> buckets = minioProperties.getBuckets();

        if (!buckets.containsKey(bucketType)) {
            throw new IllegalArgumentException("Invalid bucket type: " + bucketType);
        }

        String bucketName = buckets.get(bucketType);

        minioClient.removeObject(
                RemoveObjectArgs.builder()
                        .bucket(bucketName)
                        .object(filename)
                        .build());
    }

    @Override
    public String getDocumentUrl(String bucketType, String filename, int expirySeconds) throws Exception {
        Map<String, String> buckets = minioProperties.getBuckets();

        if (!buckets.containsKey(bucketType)) {
            throw new IllegalArgumentException("Invalid bucket type: " + bucketType);
        }

        String bucketName = buckets.get(bucketType);

        return minioClient.getPresignedObjectUrl(
                GetPresignedObjectUrlArgs.builder()
                        .method(Method.GET)
                        .bucket(bucketName)
                        .object(filename)
                        .expiry(expirySeconds, TimeUnit.SECONDS)
                        .build());
    }
}