package zw.co.kenac.takeu.backend.service.client.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntity;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntityResponseDto;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.service.client.ClientProfileService;

import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ClientProfileServiceImpl implements ClientProfileService {
    private final ClientRepository clientRepository;

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
                .addressEntered(a.getAddressEntered())
                .title(a.getTitle())
                .isDefault(a.getIsDefault())
                .geohash(a.getGeohash())
                .longitude(a.getLongitude())
                .addressFormatted(a.getAddressFormatted())
                .latitude(a.getLatitude())
                .clientId(a.getClient().getEntityId()).build();
    }
}
