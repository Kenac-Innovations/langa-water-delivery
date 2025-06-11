package zw.co.kenac.takeu.backend.dto.driver;

import jakarta.validation.constraints.NotNull;
import org.springframework.web.multipart.MultipartFile;

public record DriverVehicleRequest(
        String vehicleModel,
        String vehicleColor,
        String vehicleMake,
        String licensePlateNo,
        Boolean active,
        String vehicleType,
        String vehicleStatus,
        MultipartFile registrationBookFile,
        MultipartFile frontImageFile,
        MultipartFile backImageFile,
        MultipartFile sideImageFile

) {
}
