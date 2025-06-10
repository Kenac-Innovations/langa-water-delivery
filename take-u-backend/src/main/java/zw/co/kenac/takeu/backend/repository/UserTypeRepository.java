package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.UserTypeEntity;

import java.util.Optional;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 22/4/2025
 */
@Repository
public interface UserTypeRepository extends JpaRepository<UserTypeEntity, Long> {
    Optional<UserTypeEntity> findUserTypeByTypeName(String typeName);
}
