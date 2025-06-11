package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.springframework.data.domain.Persistable;

import java.io.Serializable;

@MappedSuperclass
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Setter
@SuperBuilder
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
