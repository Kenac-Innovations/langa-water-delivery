package zw.co.kenac.takeu.backend.config;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.util.HashMap;
import java.util.Map;

@Configuration
@RequiredArgsConstructor
public class MinioConfig {

    // Primary MinIO server configuration
    @Value("${minio.primary.endpoint:${minio.endpoint}}")
    private String primaryEndpoint;

    @Value("${minio.primary.accessKey:${minio.accessKey}}")
    private String primaryAccessKey;

    @Value("${minio.primary.secretKey:${minio.secretKey}}")
    private String primarySecretKey;

    @Value("${minio.primary.region:${minio.region:us-east-1}}")
    private String primaryRegion;

    // Secondary MinIO server configuration
    @Value("${minio.secondary.endpoint}")
    private String secondaryEndpoint;

    @Value("${minio.secondary.accessKey}")
    private String secondaryAccessKey;

    @Value("${minio.secondary.secretKey}")
    private String secondarySecretKey;

    @Value("${minio.secondary.region:us-east-1}")
    private String secondaryRegion;

    @ConfigurationProperties(prefix = "minio")
    public static class MinioProperties {
        // Original buckets map for backward compatibility
        private Map<String, String> buckets = new HashMap<>();
        // New structure for multi-server configuration
        private Map<String, Map<String, String>> servers = new HashMap<>();

        public Map<String, String> getBuckets() {
            return buckets;
        }

        public void setBuckets(Map<String, String> buckets) {
            this.buckets = buckets;
        }

        public Map<String, Map<String, String>> getServers() {
            return servers;
        }

        public void setServers(Map<String, Map<String, String>> servers) {
            this.servers = servers;
        }
    }

    @Bean
    public MinioProperties minioProperties() {
        return new MinioProperties();
    }

    @Bean
    @Primary
    public MinioClient minioClient(MinioProperties minioProperties) throws Exception {
        // Primary MinIO client with region
        MinioClient minioClient = MinioClient.builder()
                .endpoint(primaryEndpoint)
                .credentials(primaryAccessKey, primarySecretKey)
                .region(primaryRegion)
                .build();

        // Initialize legacy buckets configuration
        for (Map.Entry<String, String> entry : minioProperties.getBuckets().entrySet()) {
            String bucketName = entry.getValue();
            boolean found = minioClient.bucketExists(BucketExistsArgs.builder()
                    .bucket(bucketName)
                    .build());
            if (!found) {
                minioClient.makeBucket(MakeBucketArgs.builder()
                        .bucket(bucketName)
                        .region(primaryRegion)
                        .build());
            }
        }

        // Initialize primary server buckets if configured
        if (minioProperties.getServers().containsKey("primary")) {
            Map<String, String> primaryBuckets = minioProperties.getServers().get("primary");
            if (primaryBuckets != null) {
                for (Map.Entry<String, String> entry : primaryBuckets.entrySet()) {
                    String bucketName = entry.getValue();
                    boolean found = minioClient.bucketExists(BucketExistsArgs.builder()
                            .bucket(bucketName)
                            .build());
                    if (!found) {
                        minioClient.makeBucket(MakeBucketArgs.builder()
                                .bucket(bucketName)
                                .region(primaryRegion)
                                .build());
                    }
                }
            }
        }

        return minioClient;
    }

    @Bean(name = "secondaryMinioClient")
    public MinioClient secondaryMinioClient(MinioProperties minioProperties) throws Exception {
        // Secondary MinIO client with region
        MinioClient secondaryClient = MinioClient.builder()
                .endpoint(secondaryEndpoint)
                .credentials(secondaryAccessKey, secondarySecretKey)
                .region(secondaryRegion)
                .build();

        // Initialize secondary server buckets if configured
        if (minioProperties.getServers().containsKey("secondary")) {
            Map<String, String> secondaryBuckets = minioProperties.getServers().get("secondary");
            if (secondaryBuckets != null) {
                for (Map.Entry<String, String> entry : secondaryBuckets.entrySet()) {
                    String bucketName = entry.getValue();
                    boolean found = secondaryClient.bucketExists(BucketExistsArgs.builder()
                            .bucket(bucketName)
                            .build());
                    if (!found) {
                        secondaryClient.makeBucket(MakeBucketArgs.builder()
                                .bucket(bucketName)
                                .region(secondaryRegion)
                                .build());
                    }
                }
            }
        }

        return secondaryClient;
    }

    // Original bean for backward compatibility
    @Bean
    public Map<String, String> minioBuckets(MinioProperties minioProperties) {
        return minioProperties.getBuckets();
    }

    // New bean for multi-server configuration
    @Bean(name = "serverBuckets")
    public Map<String, Map<String, String>> serverBuckets(MinioProperties minioProperties) {
        return minioProperties.getServers();
    }
}