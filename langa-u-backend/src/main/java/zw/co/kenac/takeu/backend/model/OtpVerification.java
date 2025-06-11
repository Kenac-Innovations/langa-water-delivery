package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "ms_otp_verification")
public class OtpVerification extends AbstractEntity {

    @Column(length = 6)
    private String otp;

    private LocalDateTime expiryDate;
    private Boolean expired;
    private Boolean verified;
    private String email;
    private String phoneNumber;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "entity_id")
    private UserEntity user;

}
