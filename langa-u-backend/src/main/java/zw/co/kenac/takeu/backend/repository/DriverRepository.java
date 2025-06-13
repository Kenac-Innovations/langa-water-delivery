package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.DriverEntity;

@Repository
public interface DriverRepository extends JpaRepository<DriverEntity, Long> {

    Page<DriverEntity> findAllByApprovalStatus(Pageable pageable, String staus);

}
