package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.UserEntity;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<UserEntity, Long> {

    @Query("SELECT u FROM UserEntity u WHERE u.emailAddress = :loginId OR u.mobileNumber = :loginId")
    Optional<UserEntity> findByEmailAddressOrMobileNumber(@Param("loginId") String loginId);

    @Query("SELECT u FROM UserEntity u WHERE (u.emailAddress = :loginId OR u.mobileNumber = :loginId) AND u.userType = :role")
    Optional<UserEntity> findByEmailAddressOrMobileNumberAndRole(@Param("loginId") String loginId, @Param("role") String role);

    Page<UserEntity> findAllByUserType(Pageable pageable, String userType);

}
