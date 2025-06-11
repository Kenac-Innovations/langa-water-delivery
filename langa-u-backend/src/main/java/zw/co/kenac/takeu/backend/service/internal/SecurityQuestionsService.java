package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.auth.client.SecurityQuestionDto;
import zw.co.kenac.takeu.backend.model.SecurityQuestionsEntity;

import java.util.List;

public interface SecurityQuestionsService {
    
    SecurityQuestionsEntity createQuestion(String question);
    
    List<SecurityQuestionsEntity> getAllQuestions();
    
    List<SecurityQuestionDto> getRandomQuestions();
    
    SecurityQuestionsEntity updateQuestion(Long id, String question);
    
    void deleteQuestion(Long id);
} 