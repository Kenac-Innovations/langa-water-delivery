package zw.co.kenac.takeu.backend.service.client.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.client.ClientAddressRequestDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntity;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntityResponseDto;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.repository.ClientAddressRepository;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.service.client.ClientProfileService;

import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ClientProfileServiceImpl implements ClientProfileService {
    private final ClientRepository clientRepository;
    private final ClientAddressRepository clientAddressRepository;

    @Override
    public void setAddressAsDefault(Long clientId, Long addressId) {
        ClientEntity clientEntity = clientRepository.findById(clientId).orElseThrow(()-> new ResourceNotFoundException("Client not found with ID: " + clientId));
        List<ClientAddressesEntity> clientAddressesEntityList = clientEntity.getClientAddresses();
        List<ClientAddressesEntity> updatedList = clientAddressesEntityList.stream().map(x->{
            if(x.getEntityId().equals(addressId)){
                x.setIsDefault(true);
                return x;
            }
            x.setIsDefault(false);
            return x;
        }).toList();
        clientAddressesEntityList.clear();
        clientAddressesEntityList.addAll(updatedList);
        try{
            clientRepository.save(clientEntity);
        }catch (Exception e){
            e.printStackTrace();
            throw new RuntimeException("Error setting address with ID: " + addressId + " as default for client with ID: " + clientId + " "+e.getMessage());
        }

    }

    @Override
    public void deleteAddress(Long clientId, Long addressId) {
        ClientEntity clientEntity = clientRepository.findById(clientId).orElseThrow(()-> new ResourceNotFoundException("Client not found with ID: " + clientId));
        List<ClientAddressesEntity> clientAddressesEntityList = clientEntity.getClientAddresses();
        List<ClientAddressesEntity> updatedList = clientAddressesEntityList.stream().filter(x-> !Objects.equals(x.getEntityId(), addressId)).toList();
        clientAddressesEntityList.clear();
        clientAddressesEntityList.addAll(updatedList);
        try{
            clientRepository.save(clientEntity);
        }catch (Exception e){
            e.printStackTrace();
            throw new RuntimeException("Error deleting address with ID: " + addressId + " for client with ID: " + clientId + " "+e.getMessage());
        }
    }

    @Override
    public List<ClientAddressesEntityResponseDto> getAddresses(Long clientId) {
        ClientEntity clientEntity = clientRepository.findById(clientId).orElseThrow(()-> new ResourceNotFoundException("Client not found with ID: " + clientId));

        return clientEntity.getClientAddresses().stream().map(this::convertToDto).toList() ;
    }
    private ClientAddressesEntityResponseDto convertToDto(ClientAddressesEntity a){

        return ClientAddressesEntityResponseDto.builder()
                .entityId(a.getEntityId())
                .addressEntered(a.getAddressEntered())
                .title(a.getTitle())
                .isDefault(a.getIsDefault())
                .geohash(a.getGeohash())
                .longitude(a.getLongitude())
                .addressFormatted(a.getAddressFormatted())
                .latitude(a.getLatitude())
                .clientId(a.getClient().getEntityId()).build();
    }

    @Override
    public void createAddress(ClientAddressRequestDto dto) {
        ClientEntity client = clientRepository.findById(dto.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with ID: " + dto.getClientId()));

        ClientAddressesEntity entity = ClientAddressesEntity.builder()
                .title(dto.getTitle())
                .addressEntered(dto.getAddressEntered())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .addressFormatted(dto.getAddressFormatted())
                .isDefault(false)
                .client(client)
                .build();

        // Force geohash update (since builder skips setter logic)
        entity.setLatitude(dto.getLatitude());
        entity.setLongitude(dto.getLongitude());

        clientAddressRepository.save(entity);
    }

    @Override
    public void updateAddress(Long addressId, ClientAddressRequestDto dto) {
        ClientAddressesEntity entity = clientAddressRepository.findById(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("Address not found with ID: " + addressId));

        entity.setTitle(dto.getTitle());
        entity.setAddressEntered(dto.getAddressEntered());
        entity.setLatitude(dto.getLatitude());
        entity.setLongitude(dto.getLongitude());
        entity.setAddressFormatted(dto.getAddressFormatted());
        // geohash is auto-updated via setters

        clientAddressRepository.save(entity);
    }
}
