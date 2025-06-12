package zw.co.kenac.takeu.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import zw.co.kenac.takeu.backend.model.base.AbstractEntity;

@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sp_errand_items")
public class ErrandItemEntity extends AbstractEntity {

    @ManyToOne
    @JoinColumn(name = "errand_id", referencedColumnName = "entity_id")
    private ErrandEntity errand;
}
