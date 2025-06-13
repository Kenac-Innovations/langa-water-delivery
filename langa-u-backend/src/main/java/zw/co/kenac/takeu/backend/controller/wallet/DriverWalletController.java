package zw.co.kenac.takeu.backend.controller.wallet;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.walletmodule.dto.*;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@RestController
@RequestMapping(value = "/api/v1/driver-wallet")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Driver Wallet Controller", description = "Endpoints for Driver Wallet Operations")
public class DriverWalletController {
    private final TransactionService transactionService;

    @Operation(summary = "Create a deposit request to a driver's wallet")
    @PostMapping("/deposit")
    public ResponseEntity<GenericResponse<TransactionDto>> wallerDriverDepositRequest(
            @RequestBody DriverDepositRequestDTO depositRequest) {
        log.info("========> Create Deposit Request API: {}", depositRequest);
        TransactionDto transaction = transactionService.depositToDriverWallet(depositRequest);
        return ResponseEntity.ok(GenericResponse.success(transaction));
    }

    @Operation(summary = "Process the completion of a deposit transaction")
    @PostMapping("/deposit/complete")
    public ResponseEntity<GenericResponse<Transaction>> completeDeposit(
            @RequestBody ProcessPaymentResponseDTO completeRequest) {
        log.info("========> Complete Deposit API: {}", completeRequest);
        return ResponseEntity.ok(GenericResponse.success(transactionService.processWalletDepositPayment(completeRequest)));
    }

    @Operation(summary = "Create a withdrawal request from a driver's wallet")
    @PostMapping("/withdrawal")
    public ResponseEntity<GenericResponse<DriverWalletTransactionResponseDTO>> createWithdrawalRequest(
            @RequestBody DriverWithdrawalRequestDTO withdrawalRequest) {
        log.info("========> Create Withdrawal Request API: {}", withdrawalRequest);
        Transaction transaction = transactionService.withdrawFromDriverWallet(
                withdrawalRequest.getDriverId(),
                withdrawalRequest.getAmount(),
                withdrawalRequest.getCurrencyId(),
                withdrawalRequest.getPaymentMethod()
        );

        DriverWalletTransactionResponseDTO response = DriverWalletTransactionResponseDTO.builder()
                .transactionId(transaction.getId())
                .driverId(transaction.getDriverId())
                .amount(transaction.getPrincipalAmount())
                .currencyCode(transaction.getCurrencies().getName())
                .type(transaction.getType())
                .status(transaction.getStatus())
                .reference(transaction.getReference())
                .build();

        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Process the completion of a withdrawal transaction")
    @PostMapping("/withdrawal/complete")
    public ResponseEntity<GenericResponse<Transaction>> completeWithdrawal(
            @RequestBody CompleteTransactionDTO completeRequest) {
        log.info("========> Complete Withdrawal API: {}", completeRequest);

        // Convert to ProcessPaymentResponseDTO since the implementation uses it
        ProcessPaymentResponseDTO paymentResponse = ProcessPaymentResponseDTO.builder()
                .txnId(completeRequest.getTransactionId())
                .status(completeRequest.getStatus())
                .narration(completeRequest.getNarration())
                .build();

        Transaction response = transactionService.processEMoneyPayment(paymentResponse);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
} 