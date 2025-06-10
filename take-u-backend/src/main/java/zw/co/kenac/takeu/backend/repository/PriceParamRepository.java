package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.PriceParamEntity;

@Repository
public interface PriceParamRepository extends JpaRepository<PriceParamEntity, Long> {
}
