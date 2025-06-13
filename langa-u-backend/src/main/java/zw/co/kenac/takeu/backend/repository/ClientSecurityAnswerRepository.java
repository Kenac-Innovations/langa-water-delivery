package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.ClientSecurityAnswerEntity;

import java.util.List;

@Repository
public interface ClientSecurityAnswerRepository extends JpaRepository<ClientSecurityAnswerEntity, Long> {
    
    List<ClientSecurityAnswerEntity> findByClient(ClientEntity client);
} 