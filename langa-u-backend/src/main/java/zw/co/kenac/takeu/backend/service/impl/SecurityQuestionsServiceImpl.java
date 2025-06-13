package zw.co.kenac.takeu.backend.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.auth.client.SecurityQuestionDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.SecurityQuestionsEntity;
import zw.co.kenac.takeu.backend.repository.SecurityQuestionsRepository;
import zw.co.kenac.takeu.backend.service.internal.SecurityQuestionsService;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SecurityQuestionsServiceImpl implements SecurityQuestionsService {

    private final SecurityQuestionsRepository securityQuestionsRepository;

    @Override
    public SecurityQuestionsEntity createQuestion(String question) {
        SecurityQuestionsEntity securityQuestion = SecurityQuestionsEntity.builder()
                .question(question)
                .build();
        return securityQuestionsRepository.save(securityQuestion);
    }

    @Override
    public List<SecurityQuestionsEntity> getAllQuestions() {
        return securityQuestionsRepository.findAll();
    }

    @Override
    public List<SecurityQuestionDto> getRandomQuestions() {
        List<SecurityQuestionsEntity> randomQuestions = securityQuestionsRepository.findRandomQuestions();
        return randomQuestions.stream()
                .map(question -> SecurityQuestionDto.builder()
                        .id(question.getEntityId())
                        .question(question.getQuestion())
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public SecurityQuestionsEntity updateQuestion(Long id, String question) {
        SecurityQuestionsEntity existingQuestion = securityQuestionsRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Security question not found with id: " + id));
        
        existingQuestion.setQuestion(question);
        return securityQuestionsRepository.save(existingQuestion);
    }

    @Override
    public void deleteQuestion(Long id) {
        if (!securityQuestionsRepository.existsById(id)) {
            throw new ResourceNotFoundException("Security question not found with id: " + id);
        }
        securityQuestionsRepository.deleteById(id);
    }
} 