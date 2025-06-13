package zw.co.kenac.takeu.backend.dto.auth.driver;

import jakarta.validation.constraints.NotNull;
import org.springframework.web.multipart.MultipartFile;

public record DriverRegisterRequest(
        @NotNull String phoneNumber,
        @NotNull String email,
        String firstname,
        String lastname,
        String middleName,
        @NotNull String password,
        String gender,
        String address,
        @NotNull String nationalIdNumber,
        @NotNull MultipartFile profilePhoto,
        @NotNull MultipartFile nationalIdImage,
        @NotNull MultipartFile driversLicenseImage
) { }
