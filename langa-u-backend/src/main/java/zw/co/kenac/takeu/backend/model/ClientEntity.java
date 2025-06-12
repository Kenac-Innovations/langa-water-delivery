package zw.co.kenac.takeu.backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;
import zw.co.kenac.takeu.backend.model.enumeration.ClientStatus;
import zw.co.kenac.takeu.backend.model.enumeration.CommChannels;

import java.util.List;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Table(name = "ms_client")
public class ClientEntity extends AbstractEntity {
    private String fullName;

    private String middleName;

    private String lastname;
    private Boolean isCreditAllowed;

    private String mobileNumber;
    @ElementCollection(targetClass = CommChannels.class)
    @CollectionTable(name = "client_communication_channels", joinColumns = @JoinColumn(name = "client_id"))
    @Enumerated(EnumType.STRING)
    private List<CommChannels> communicationChannels;

    private String emailAddress;
    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ClientAddressesEntity> clientAddresses;
    
    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ClientSecurityAnswerEntity> securityAnswers;
    
    @Enumerated(EnumType.STRING)
    private ClientStatus status = ClientStatus.ACTIVE;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_entity_id", referencedColumnName = "entity_id")
    @JsonBackReference
    private UserEntity userEntity;

}
