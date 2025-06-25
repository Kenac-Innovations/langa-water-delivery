package zw.co.kenac.takeu.backend.controller.waterdelivery;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.client.ClientPaymentCardRequestDto;
import zw.co.kenac.takeu.backend.dto.client.ClientPaymentCardResponseDto;
import zw.co.kenac.takeu.backend.service.client.ClientPaymentCardService;

import java.util.List;

/**
 * @author Joy Pedze
 * Date: 25 Jun 2025
 * Project: langa-u-backend
 * Package: zw.co.kenac.takeu.backend.controller.waterdelivery
 */

@RestController
@RequestMapping("/api/v2/payment-cards")
@RequiredArgsConstructor
@Tag(name = "Payment Cards", description = "Manage client payment cards")
public class ClientPaymentCardController {
    private final ClientPaymentCardService cardService;

    @PostMapping("/create")
    public ResponseEntity<GenericResponse<String>> create(@RequestBody ClientPaymentCardRequestDto dto) {
        cardService.createCard(dto);
        return ResponseEntity.ok(GenericResponse.success("Card created"));
    }

    @PutMapping("/update/{cardId}")
    public ResponseEntity<GenericResponse<String>> update(@PathVariable Long cardId,
                                                          @RequestBody ClientPaymentCardRequestDto dto) {
        cardService.updateCard(cardId, dto);
        return ResponseEntity.ok(GenericResponse.success("Card updated"));
    }

    @DeleteMapping("/delete/{cardId}")
    public ResponseEntity<GenericResponse<String>> delete(@PathVariable Long cardId) {
        cardService.deleteCard(cardId);
        return ResponseEntity.ok(GenericResponse.success("Card deleted"));
    }

    @GetMapping("/client/{clientId}")
    public ResponseEntity<GenericResponse<List<ClientPaymentCardResponseDto>>> getCards(@PathVariable Long clientId) {
        return ResponseEntity.ok(GenericResponse.success(cardService.getCardsByClient(clientId)));
    }

    @PutMapping("/set-default")
    public ResponseEntity<GenericResponse<String>> setDefault(@RequestParam Long clientId, @RequestParam Long cardId) {
        cardService.setDefaultCard(clientId, cardId);
        return ResponseEntity.ok(GenericResponse.success("Card set as default"));
    }
}

