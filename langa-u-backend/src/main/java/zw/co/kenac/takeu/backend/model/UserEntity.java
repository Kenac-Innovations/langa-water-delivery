package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

import java.time.LocalDateTime;

@Entity
@Builder
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(
        name = "ms_users",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"email_address", "user_type"}),
                @UniqueConstraint(columnNames = {"mobile_number", "user_type"})
        }
)// todo use role based login and so that same login credential can be used for multiple profiles
public class UserEntity extends AbstractEntity {

    private String firstname;

    private String middleName;

    private String lastname;

    private String mobileNumber;

    private String emailAddress;

    private String userPassword;

    private String userType;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime dateJoined;

    @OneToOne(mappedBy = "userEntity")
    private DriverEntity driver;

    @OneToOne(mappedBy = "userEntity")
    private ClientEntity customer;

    private boolean enabled;

    private boolean accountNonExpired;

    private boolean credentialsNonExpired;

    private boolean accountNonLocked;

    @OneToOne(mappedBy = "user")
    private OtpVerification verification;

    private LocalDateTime passwordChangedAt;
}
