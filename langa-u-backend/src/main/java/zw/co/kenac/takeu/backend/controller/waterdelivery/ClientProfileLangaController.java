package zw.co.kenac.takeu.backend.controller.waterdelivery;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.ClientRegisterRequestDto;
import zw.co.kenac.takeu.backend.dto.auth.client.LoginResponseDto;
import zw.co.kenac.takeu.backend.dto.auth.client.OtpRequest;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntityResponseDto;
import zw.co.kenac.takeu.backend.service.client.ClientProfileService;

import java.util.List;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@RestController
@RequestMapping("/api/v2/client-profile")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Client Profile actions ", description = "Endpoints for managing client profile")
public class ClientProfileLangaController {
    private final ClientProfileService clientProfileService;

    @Operation(summary = "Setting client address as default ")
    @PutMapping("/address/set-default")
    public ResponseEntity<GenericResponse<String>> astAddressAsDefault(@RequestParam Long clientId, @RequestParam Long addressId) {
        clientProfileService.setAddressAsDefault(clientId, addressId);
        return ResponseEntity.ok(GenericResponse.success("The address was successfully set as default"));
    }

    @Operation(summary = "Deleting an address from address book ")
    @PutMapping("/address/delete")
    public ResponseEntity<GenericResponse<String>> registerClient(
            @RequestParam Long clientId, @RequestParam Long addressId) {
        clientProfileService.deleteAddress(clientId, addressId);
        return ResponseEntity.ok(GenericResponse.success("Address successfully deleted"));
    }

    @Operation(summary = "Getting all client address ")
    @GetMapping("/address/getbyclient/{clientId}")
    public ResponseEntity<GenericResponse<List<ClientAddressesEntityResponseDto>>> getAllClientAddresses(
            @PathVariable Long clientId) {

        return ResponseEntity.ok(GenericResponse.success(clientProfileService.getAddresses(clientId)));
    }

}
