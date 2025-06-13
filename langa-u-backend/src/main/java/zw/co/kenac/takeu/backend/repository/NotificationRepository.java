package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.NotificationEntity;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<NotificationEntity, Long> {
    Page<NotificationEntity> findByUserEntityId(Long userId, Pageable pageable);
    Page<NotificationEntity> findByUserEntityIdAndRead(Long userId, boolean read, Pageable pageable);
    List<NotificationEntity> findTop5ByUserEntityIdOrderByCreatedAtDesc(Long userId);
    
    @Modifying
    @Query("UPDATE NotificationEntity n SET n.read = true WHERE n.user.entityId = :userId AND n.read = false")
    void markAllAsReadForUser(Long userId);
    
    Long countByUserEntityIdAndRead(Long userId, boolean read);
}
