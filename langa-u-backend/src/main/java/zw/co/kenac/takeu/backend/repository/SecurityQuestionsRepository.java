package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.SecurityQuestionsEntity;

import java.util.List;

@Repository
public interface SecurityQuestionsRepository extends JpaRepository<SecurityQuestionsEntity, Long> {

    @Query(value = "SELECT * FROM ms_security_question ORDER BY RANDOM() LIMIT 2", nativeQuery = true)
    List<SecurityQuestionsEntity> findRandomQuestions();
} 