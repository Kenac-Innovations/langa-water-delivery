package zw.co.kenac.takeu.backend.controller.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.internal.DispatchSettingsController;

import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.DispatchSettingsRequest;
import zw.co.kenac.takeu.backend.model.waterdelivery.DispatchSettings;
import zw.co.kenac.takeu.backend.service.internal.DispatchSettingsService;


@RestController
@RequiredArgsConstructor
public class DispatchSettingsControllerImpl implements DispatchSettingsController {

    private final DispatchSettingsService dispatchSettingsService;

    @Override
    @PutMapping
    public ResponseEntity<GenericResponse<DispatchSettings>> updateDispatchStatus(@RequestBody DispatchSettingsRequest request) {
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Dispatch status updated successfully",
                dispatchSettingsService.updateDispatchStatus(request.isStatus())
        ));
    }

    @Override
    @GetMapping
    public ResponseEntity<GenericResponse<DispatchSettings>> getDispatchStatus() {
        return ResponseEntity.ok(new GenericResponse<>(
                true,
                "Dispatch status retrieved successfully",
                dispatchSettingsService.getDispatchStatus()
        ));
    }
} 