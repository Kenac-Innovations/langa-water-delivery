package zw.co.kenac.takeu.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.database.FirebaseDatabase;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.io.InputStream;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = new ClassPathResource("firebase.json").getInputStream();

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .setDatabaseUrl("https://takeu-1f5d3-default-rtdb.firebaseio.com")
                        .build();

                FirebaseApp.initializeApp(options);
                log.info("Firebase application has been initialized");
            }
            return FirebaseApp.getInstance();
        } catch (IOException e) {
            log.error("Error initializing Firebase: {}", e.getMessage());
            throw new RuntimeException("Error initializing Firebase", e);
        }
    }

    @Bean
    public FirebaseDatabase firebaseDatabase(FirebaseApp firebaseApp) {
        FirebaseDatabase database = FirebaseDatabase.getInstance(firebaseApp);
       // database.setPersistenceEnabled(true); todo this is the thing that gave me issue nxaaa
        log.info("Firebase database has been initialized");
        return database;
    }
} 