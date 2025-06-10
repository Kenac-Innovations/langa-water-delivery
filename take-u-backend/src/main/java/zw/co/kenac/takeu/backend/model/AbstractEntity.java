package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import org.springframework.data.domain.Persistable;

import java.io.Serializable;

@MappedSuperclass
public abstract class AbstractEntity implements /*Persistable<Long>,*/ Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "entity_id")
    private Long entityId;

    /*@Transient
    private boolean isNew = true;*/

    public Long getEntityId() {
        return entityId;
    }

    /*protected void setEntityId(Long entityId) {
        this.entityId = entityId;
    }

    @Override
    public boolean isNew() {
        return isNew;
    }

    @PrePersist
    @PostLoad
    void markNotNew() {
        this.isNew = false;
    }*/
}
