package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.OtpVerification;
import zw.co.kenac.takeu.backend.model.UserEntity;

import java.util.Optional;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
@Repository
public interface OtpVerificationRepository extends JpaRepository<OtpVerification, Long> {

    Optional<OtpVerification> findByUserAndOtp(UserEntity user, String otp);

}
