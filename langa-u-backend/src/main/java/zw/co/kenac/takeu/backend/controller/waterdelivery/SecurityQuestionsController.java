package zw.co.kenac.takeu.backend.controller.waterdelivery;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.auth.client.SecurityQuestionDto;
import zw.co.kenac.takeu.backend.service.internal.SecurityQuestionsService;


import java.util.List;

@RestController
@RequestMapping("/api/v2/security-questions")
@RequiredArgsConstructor
@Tag(name = "Security Questions", description = "Endpoints for managing client security questions")
public class SecurityQuestionsController {

    private final SecurityQuestionsService securityQuestionsService;

    @Operation(summary = "Get all available security questions")
    @GetMapping
    public ResponseEntity<GenericResponse<List<?>>> getAllQuestions() {
        return ResponseEntity.ok(GenericResponse.success(securityQuestionsService.getAllQuestions()));
    }

    @Operation(summary = "Get a random set of security questions")
    @GetMapping("/random")
    public ResponseEntity<GenericResponse<List<SecurityQuestionDto>>> getRandomQuestions() {
        return ResponseEntity.ok(GenericResponse.success(securityQuestionsService.getRandomQuestions()));
    }

//    @Operation(summary = "Get security questions and answers for a specific client")
//    @GetMapping("/client/{clientId}")
//    public ResponseEntity<GenericResponse<List<SecurityQuestionDto>>> getClientQuestions(@PathVariable Long clientId) {
//        return ResponseEntity.ok(GenericResponse.success(securityQuestionsService.getClientQuestions(clientId)));
//    }

//    @Operation(summary = "Update a client's answer to a specific security question")
//    @PutMapping("/client/{clientId}/question/{questionId}")
//    public ResponseEntity<GenericResponse<SecurityQuestionDto>> updateClientAnswer(
//            @PathVariable Long clientId,
//            @PathVariable Long questionId,
//            @RequestBody String answer) {
//        return ResponseEntity.ok(GenericResponse.success(securityQuestionsService.updateQuestion(clientId, questionId, answer)));
//    }

    @Operation(summary = "Create a security Question")
    @PostMapping("/create/{question}")
    public ResponseEntity<GenericResponse<String>> createSecurityQuestion(
            @PathVariable String question) {
        securityQuestionsService.createQuestion(question);
        return ResponseEntity.ok(GenericResponse.success("Answer created successfully"));
    }
}