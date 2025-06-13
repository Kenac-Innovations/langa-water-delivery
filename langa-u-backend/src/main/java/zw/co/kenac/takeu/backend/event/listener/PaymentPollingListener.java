package zw.co.kenac.takeu.backend.event.listener;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import zw.co.kenac.takeu.backend.event.StartPollingEvent;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;
/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 21/5/2025
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PaymentPollingListener {
    
    private final TransactionService transactionService;

    @Async
    @EventListener(StartPollingEvent.class)
    public void handleStartPollingEvent(StartPollingEvent event) {
        log.info("Received start polling event for URL: {}, isWebBased: {}", 
            event.getPollUrl(), event.isWebBased());
        
        try {
            transactionService.checkPaymentStatus(event.getPollUrl(), event.isWebBased());
        } catch (Exception e) {
            log.error("Error occurred while polling payment status: {}", e.getMessage(), e);
        }
    }
} 