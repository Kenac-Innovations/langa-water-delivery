package zw.co.kenac.takeu.backend.walletmodule.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.walletmodule.dto.*;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;

import zw.co.paynow.core.Payment;
import zw.co.paynow.responses.MobileInitResponse;
import zw.co.paynow.responses.StatusResponse;
import zw.co.paynow.responses.WebInitResponse;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.scheduling.annotation.Async;

/**
 * Created by DylanDzvene
 * Email: dylandzvenetashinga@gmail.com
 * Created on: 4/25/2025
 */
public interface TransactionService {
    Transaction processCashPayment(ProcessPaymentResponseDTO transactionDto);
    Transaction processEMoneyPayment(ProcessPaymentResponseDTO transactionDto);
    TransactionDto createTransaction(CreateTxnDTO createTxnDTO);
    Transaction transferFunds(TransactionDto transactionDto);
    
    // Updated to use pagination
    Page<TransactionDto> getTransactionsByWalletId(Long walletId, Pageable pageable, TransactionStatus status);
    
    // Updated to use PaginatedResponse
    PaginatedResponse<TransactionDto> getTransactionsByDriverId(Long driverId, int pageNumber, int pageSize, TransactionStatus status);
    
    List<Transaction> getTransactionsByOrganizationId(Long organizationId);
    Transaction getTransactionById(String id);
    TransactionDto depositToDriverWallet(DriverDepositRequestDTO depositRequestDTO);
    Transaction processWalletDepositPayment(ProcessPaymentResponseDTO transactionDto);
    Transaction withdrawFromDriverWallet(Long driverId, BigDecimal amount, Long currencyId, PaymentMethod paymentMethod);
    WebInitResponse initiateWebPayment(Payment payment);
    MobileInitResponse initiateMobilePayment(Payment payment, String mobileNumber, String email);
    /**
     * Polls for payment status with exponential backoff and multiple retries.
     *
     * @param pollUrl The URL to poll for payment status
     * @param isWebBased Whether this is a web-based payment (true) or mobile payment (false)
     */
    @Async
    void checkPaymentStatus(String pollUrl, boolean isWebBased);
    Payment createPaynowPayment(String reference, List<PaymentItem> items);
    Payment createPaynowPaymentMobile(String reference, List<PaymentItem> items);
    Transaction processPaynowCallback(String pollUrl, StatusResponse status);
}
