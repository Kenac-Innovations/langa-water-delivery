package zw.co.kenac.takeu.backend.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 8/4/2025
 */
@Configuration
public class ApiDocConfiguration {

    @Bean
    public OpenAPI openAPI() {
        Contact contact = new Contact();
        contact.setEmail("jaisonc@kenac.co.zw");
        contact.setName("Jaison.Chipuka");
        contact.setUrl("https://kenac.co.zw");

        Server localServer = new Server();
        localServer.setUrl("");
        localServer.setDescription("Local Environment Base URL");

        Server prodServer = new Server();
        prodServer.setUrl("");
        prodServer.setDescription("Production Environment Base URL");

        SecurityRequirement securityRequirement = new SecurityRequirement();
        securityRequirement.addList("Bearer Authorization");

        Components components = new Components();
        components.addSecuritySchemes("Bearer Authentication", createApiKeyScheme());

        Info info = new Info()
                .title("Take U Backend API")
                .contact(contact)
                .version("1.0.0")
                .description("Take-U API Documentation");

        return new OpenAPI()
                .info(info)
                .servers(List.of(localServer, prodServer))
                .addSecurityItem(securityRequirement)
                .components(components);
    }

    @Bean
    public GroupedOpenApi driverOpenApi() {
        return GroupedOpenApi.builder()
                .group("Driver API")
                .pathsToMatch("/api/v1/driver/**")
                .build();
    }

    @Bean
    public GroupedOpenApi clientOpenApi() {
        return GroupedOpenApi.builder()
                .group("Customer API")
                .pathsToMatch("/api/v1/client/**")
                .build();
    }

    @Bean
    public GroupedOpenApi internalOpenApi() {
        return GroupedOpenApi.builder()
                .group("Internal API")
                .pathsToExclude("/api/v1/client/**", "/api/v1/driver/**")
                .build();
    }
    
    @Bean
    public GroupedOpenApi deviceManagementOpenApi() {
        return GroupedOpenApi.builder()
                .group("Device Management API")
                .pathsToMatch("/api/v1/users/*/devices/**", "/api/v1/drivers/*/devices/**", "/api/v1/devices/**")
                .build();
    }

    private SecurityScheme createApiKeyScheme() {
        return new SecurityScheme().type(SecurityScheme.Type.HTTP)
                .bearerFormat("JWT")
                .scheme("bearer");
    }
}
