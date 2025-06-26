package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.DispatchSettings;


@Repository
public interface DispatchSettingsRepository extends JpaRepository<DispatchSettings, Long> {
} 