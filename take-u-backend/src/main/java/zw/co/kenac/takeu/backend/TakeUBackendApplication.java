package zw.co.kenac.takeu.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@EnableAsync
@SpringBootApplication
public class TakeUBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(TakeUBackendApplication.class, args);
    }

}
