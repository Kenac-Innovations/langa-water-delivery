package zw.co.kenac.takeu.backend.controller.wallet;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.walletmodule.dto.CreateTxnDTO;
import zw.co.kenac.takeu.backend.walletmodule.dto.ProcessPaymentResponseDTO;
import zw.co.kenac.takeu.backend.walletmodule.dto.TransactionDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;

import java.util.List;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/27/2025
 */


@RestController
@RequestMapping(value = "/api/v1/transactions")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Transaction Controller", description = "Endpoints for Transaction Management")
public class TransactionController {
    private final TransactionService transactionService;

    @Operation(summary = "Process a payment transaction")
    @PostMapping("/process-cash-payment")
    public ResponseEntity<GenericResponse<Transaction>> processPayment(@RequestBody ProcessPaymentResponseDTO paymentResponseDTO) {
        log.info("========> Process CASH Payment API request {}", paymentResponseDTO);
        Transaction response = transactionService.processCashPayment(paymentResponseDTO);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Process E-Money Payment for webhook from payment gateway")
    @PostMapping("/process-emoney-payment")
    public ResponseEntity<GenericResponse<Transaction>> processEMoneyPaymentFromPaymentResponse(@RequestBody ProcessPaymentResponseDTO paymentResponseDTO) {
        log.info("========> Process E-Money Payment API request {}", paymentResponseDTO);
        Transaction response = transactionService.processEMoneyPayment(paymentResponseDTO);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Process a cash deposit payment transaction", 
               description = "Processes a cash deposit payment transaction after confirmation from payment system or manual entry")
    @PostMapping("/process-cash-deposit")
    public ResponseEntity<GenericResponse<Transaction>> processCashDepositPayment(@RequestBody ProcessPaymentResponseDTO paymentResponseDTO) {
        log.info("========> Process Cash Deposit Payment API request {}", paymentResponseDTO);
        Transaction response = transactionService.processWalletDepositPayment(paymentResponseDTO);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Create a new transaction")
    @PostMapping
    public ResponseEntity<GenericResponse<TransactionDto>> createTransaction(@RequestBody CreateTxnDTO createTxnDTO) {
        log.info("========> Create Transaction API request {}", createTxnDTO);
        TransactionDto response = transactionService.createTransaction(createTxnDTO);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Transfer funds between wallets")
    @PostMapping("/transfer")
    public ResponseEntity<GenericResponse<Transaction>> transferFunds(@RequestBody TransactionDto transactionDto) {
        log.info("========> Transfer Funds API request {}", transactionDto);
        Transaction response = transactionService.transferFunds(transactionDto);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get transactions by wallet ID (paginated)",
              description = "Returns paginated transactions for a wallet with optional status filtering")
    @GetMapping("/wallet/{walletId}")
    public ResponseEntity<GenericResponse<Page<TransactionDto>>> getTransactionsByWalletId(
            @PathVariable Long walletId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) TransactionStatus status) {
        
        log.info("========> Get Transactions by Wallet ID API for wallet {}, page {}, size {}, status {}", 
                walletId, page, size, status);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by("dateCreated").descending());
        Page<TransactionDto> response = transactionService.getTransactionsByWalletId(walletId, pageable, status);
        
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get transactions by driver ID (paginated)",
              description = "Returns paginated transactions for a driver with optional status filtering")
    @GetMapping("/driver/{driverId}")
    public ResponseEntity<GenericResponse<PaginatedResponse<TransactionDto>>> getTransactionsByDriverId(
            @PathVariable Long driverId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "15") int pageSize,
            @RequestParam(required = false) TransactionStatus status) {
        
        log.info("========> Get Transactions by Driver ID API for driver {}, page {}, size {}, status {}", 
                driverId, pageNumber, pageSize, status);
        
        PaginatedResponse<TransactionDto> response = transactionService.getTransactionsByDriverId(
            driverId, pageNumber, pageSize, status);
        
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get transactions by organization ID")
    @GetMapping("/organization/{organizationId}")
    public ResponseEntity<GenericResponse<List<Transaction>>> getTransactionsByOrganizationId(@PathVariable Long organizationId) {
        log.info("========> Get Transactions by Organization ID API for organization {}", organizationId);
        List<Transaction> response = transactionService.getTransactionsByOrganizationId(organizationId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get transaction by ID")
    @GetMapping("/{id}")
    public ResponseEntity<GenericResponse<Transaction>> getTransactionById(@PathVariable String id) {
        log.info("========> Get Transaction by ID API for transaction {}", id);
        Transaction response = transactionService.getTransactionById(id);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
}