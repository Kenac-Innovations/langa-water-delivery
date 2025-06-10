package zw.co.kenac.takeu.backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.enumeration.ClientStatus;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Table(name = "ms_client")
public class ClientEntity extends AbstractEntity {
    private String firstname;

    private String middleName;

    private String lastname;

    private String mobileNumber;

    private String emailAddress;
    
    @Enumerated(EnumType.STRING)
    private ClientStatus status = ClientStatus.ACTIVE;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_entity_id", referencedColumnName = "entity_id")
    @JsonBackReference
    private UserEntity userEntity;

}
