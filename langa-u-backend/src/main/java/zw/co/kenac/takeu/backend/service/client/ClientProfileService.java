package zw.co.kenac.takeu.backend.service.client;

import zw.co.kenac.takeu.backend.dto.client.ClientAddressRequestDto;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntityResponseDto;

import java.util.List;

public interface ClientProfileService {
    void setAddressAsDefault(Long clientId, Long addressId);
    void deleteAddress(Long clientId, Long addressId);
    void createAddress(ClientAddressRequestDto dto);
    void updateAddress(Long addressId, ClientAddressRequestDto dto);
    List<ClientAddressesEntityResponseDto> getAddresses(Long clientId);

}
