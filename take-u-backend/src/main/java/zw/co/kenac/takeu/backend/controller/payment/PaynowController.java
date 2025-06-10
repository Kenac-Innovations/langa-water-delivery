package zw.co.kenac.takeu.backend.controller.payment;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.walletmodule.dto.PaynowPaymentRequest;
import zw.co.kenac.takeu.backend.walletmodule.dto.PaynowMobilePaymentRequest;
import zw.co.kenac.takeu.backend.walletmodule.dto.ProcessPaymentResponseDTO;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;
import zw.co.kenac.takeu.backend.walletmodule.dto.CreateFirebaseTransactionDTO;
import zw.co.kenac.takeu.backend.service.internal.FirebaseService;

import zw.co.paynow.core.Payment;
import zw.co.paynow.responses.MobileInitResponse;
import zw.co.paynow.responses.StatusResponse;
import zw.co.paynow.responses.WebInitResponse;

import org.springframework.http.HttpStatus;

import java.util.List;

@RestController
@RequestMapping("/api/v1/payments/paynow")
@RequiredArgsConstructor
@Slf4j
public class PaynowController {

    private final TransactionService transactionService;
    private final FirebaseService firebaseService;

    /**
     * Initiates a web-based Paynow payment
     */
    @PostMapping("/web")
    public ResponseEntity<GenericResponse<WebInitResponse>> initiateWebPayment(
            @RequestBody PaynowPaymentRequest request) {
        log.info("Initiating web payment for reference: {}", request.getReference());
        
        Payment payment = transactionService.createPaynowPayment(
            request.getReference(), 
            request.getItems()
        );
        
        WebInitResponse response = transactionService.initiateWebPayment(
            payment
        );
        transactionService.checkPaymentStatus(response.pollUrl(),true);
        
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    /**
     * Initiates a mobile-based Paynow payment
     */
    @PostMapping("/mobile")
    public ResponseEntity<GenericResponse<MobileInitResponse>> initiateMobilePayment(
            @RequestBody PaynowMobilePaymentRequest request) {
        log.info("Initiating mobile payment for reference: {}", request.getReference());
        
        Payment payment = transactionService.createPaynowPaymentMobile(
            request.getReference(), 
            request.getItems()
        );
        
        MobileInitResponse response = transactionService.initiateMobilePayment(
            payment,
            request.getMobileNumber(),
            request.getEmail()
        );
        
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    /**
     * Checks the status of a Paynow payment
     */
    @GetMapping("/status")
    public ResponseEntity<GenericResponse<StatusResponse>> checkPaymentStatus(
            @RequestParam String pollUrl) {
        log.info("Checking payment status for poll URL: {}", pollUrl);
        
        //StatusResponse status = transactionService.checkPaymentStatus(pollUrl);
        return ResponseEntity.ok(GenericResponse.success(null));
    }

    /**
     * Callback endpoint for Paynow to notify about payment status
     */

    @PostMapping("/callback44")
    public ResponseEntity<GenericResponse<Transaction>> processCallback(
            @RequestParam String pollUrl,
            @RequestBody StatusResponse status) {
        log.info("Received callback for poll URL: {}", pollUrl);
        
        Transaction transaction = transactionService.processPaynowCallback(pollUrl, status);
        return ResponseEntity.ok(GenericResponse.success(transaction));
    }
    @PostMapping("/callback")
    public ResponseEntity<GenericResponse<Void>> processCallback2(
            @RequestParam("reference") String reference,
            @RequestParam("paynowreference") String paynowReference,
            @RequestParam("amount") String amount,
            @RequestParam("status") String status,
            @RequestParam("pollurl") String pollUrl,
            @RequestParam("hash") String hash) {

        log.info("=== Paynow Callback Received ===");
        log.info("Reference        : {}", reference);
        log.info("Paynow Reference : {}", paynowReference);
        log.info("Amount           : {}", amount);
        log.info("Status           : {}", status);
        log.info("Poll URL         : {}", pollUrl);
        log.info("Hash             : {}", hash);
        log.info("================================= in coming call payment callback coming");

        Transaction transaction = transactionService.processWalletDepositPayment(ProcessPaymentResponseDTO.builder()
                .txnId(reference)
                .status(TransactionStatus.fromString(status)).build());
        return ResponseEntity.ok(GenericResponse.success(null));
    }

    @PostMapping("/firebase/transaction")
    public ResponseEntity<GenericResponse<CreateFirebaseTransactionDTO>> createFirebaseTransaction(
            @RequestBody CreateFirebaseTransactionDTO transactionDTO) {
        try {
            firebaseService.createTransaction(transactionDTO);
            return ResponseEntity.ok(GenericResponse.success(transactionDTO));
        } catch (Exception e) {
            log.error("Error creating transaction in Firebase: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(GenericResponse.<CreateFirebaseTransactionDTO>error());
        }
    }
} 