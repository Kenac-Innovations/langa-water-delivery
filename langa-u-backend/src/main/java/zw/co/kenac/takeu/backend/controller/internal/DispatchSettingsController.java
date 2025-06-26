package zw.co.kenac.takeu.backend.controller.internal;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.DispatchSettingsRequest;
import zw.co.kenac.takeu.backend.model.waterdelivery.DispatchSettings;


@RequestMapping("${custom.base.path}/dispatch-settings")
@Tag(name = "Dispatch Settings Management")
public interface DispatchSettingsController {

    @Operation(
            summary = "Update auto-dispatch status",
            description = "Enables or disables the auto-dispatch feature for all open deliveries"
    )
    ResponseEntity<GenericResponse<DispatchSettings>> updateDispatchStatus(@RequestBody DispatchSettingsRequest request);

    @Operation(
            summary = "Get auto-dispatch status",
            description = "Retrieves the current status of the auto-dispatch feature"
    )
    ResponseEntity<GenericResponse<DispatchSettings>> getDispatchStatus();
} 