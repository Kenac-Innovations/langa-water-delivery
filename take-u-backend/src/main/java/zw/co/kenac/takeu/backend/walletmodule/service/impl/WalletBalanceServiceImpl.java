package zw.co.kenac.takeu.backend.walletmodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionEntryType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;
import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;
import zw.co.kenac.takeu.backend.walletmodule.models.*;
import zw.co.kenac.takeu.backend.walletmodule.repo.WalletBalanceRepo;
import zw.co.kenac.takeu.backend.walletmodule.service.CurrencyService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletBalanceService;
import zw.co.kenac.takeu.backend.walletmodule.utils.JsonUtil;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/24/2025
 */
@Service
@RequiredArgsConstructor
@Transactional
@Slf4j

public class WalletBalanceServiceImpl implements WalletBalanceService {
    private final WalletBalanceRepo walletBalanceRepo;
    private final CurrencyService currencyService;
    @Override
    public WalletBalance createWalletBalance(WalletAccount wallet, long amount, String transactionRef, Transaction transaction) {
        // Get the current running balance
        long runningBalance = 100;

        // Calculate the new running balance
        long newRunningBalance = runningBalance + amount;

        // Create new wallet balance entry
        WalletBalance walletBalance = WalletBalance.builder()
                //.driverId(UUID.randomUUID().toString())
                .wallet(wallet)
                .amount(BigDecimal.valueOf(amount))
                .runningBalance(BigDecimal.valueOf(newRunningBalance))
                .transactionRef(transactionRef)
                .transaction(null)
                .dateCreated(LocalDateTime.now())
                .build();

        log.info("======>Creating wallet balance entry for wallet: {}, amount: {}, new balance: {}",
                wallet.getAccountNumber(), amount, newRunningBalance);

        return walletBalanceRepo.save(walletBalance);
    }

    @Override
    public List<WalletBalance>  getCurrentAllBalanceForWallet(WalletAccount wallet) {
        List<WalletBalance>  walletBalanceListEmoney = walletBalanceRepo.getLatestBalanceForAllActiveCurrenciesAndType(wallet.getId(), WalletBalanceType.E_MONEY);
        List<WalletBalance>  walletBalanceListCash = walletBalanceRepo.getLatestBalanceForAllActiveCurrenciesAndType(wallet.getId(), WalletBalanceType.CASH);

        walletBalanceListEmoney.addAll(walletBalanceListCash);
        return walletBalanceListEmoney;
    }

    @Override
    public List<WalletBalance> getAllCurrentBalanceForWalletByCurrency(Long walletId, Long currencyId) {
        List<WalletBalance> walletBalanceList= new ArrayList<>();
        Optional<WalletBalance> walletBalanceOptionalE_Money= walletBalanceRepo.findTopByCurrency_IdAndWallet_IdAndBalanceTypeOrderByDateCreatedDesc(currencyId,walletId,WalletBalanceType.E_MONEY);
        Optional<WalletBalance> walletBalanceOptionalCash= walletBalanceRepo.findTopByCurrency_IdAndWallet_IdAndBalanceTypeOrderByDateCreatedDesc(currencyId,walletId,WalletBalanceType.CASH);
        if(walletBalanceOptionalCash.isEmpty()||walletBalanceOptionalE_Money.isEmpty()){
            return new ArrayList<>();
        }
        return List.of(walletBalanceOptionalE_Money.get(),walletBalanceOptionalCash.get());
    }

    @Override
    public WalletBalance getCurrentBalanceForWalletByCurrencyAndBalanceType(Long walletId, Long currencyId, WalletBalanceType balanceType) {
        Optional<WalletBalance> walletBalanceOptional= walletBalanceRepo.findTopByCurrency_IdAndWallet_IdAndBalanceTypeOrderByDateCreatedDesc(currencyId,walletId,balanceType);
        return walletBalanceOptional.orElse(null);
    }

    @Override
    public List<WalletBalance> getWalletBalanceHistory(WalletAccount wallet) {
        return walletBalanceRepo.findByWalletOrderByDateCreatedDesc(wallet);
    }

    @Override
    public List<WalletBalance> processBalanceChanges(List<SubTransaction> subTransactions) {
        List<WalletBalance> walletBalanceList= new ArrayList<>();
        for (SubTransaction s:subTransactions){
            //log.info("=====> This is the Sub Transaction Body {}", JsonUtil.toJson(s));
            WalletBalance walletBalance= getCurrentBalanceForWalletByCurrencyAndBalanceType(s.getWalletAccount().getId(),s.getCurrencies().getId(), WalletBalanceType.E_MONEY);
            if (walletBalance==null){
                log.info("=======> Could not find the balance");
                // todo implement a fall back mechanism to create the balance and use it
            }
            assert walletBalance != null;
            WalletBalance newWalletBalance;// todo refactor this
            if (s.getType().equals(TransactionEntryType.CREDIT)){
                newWalletBalance = WalletBalance.builder()
                        .currency(s.getCurrencies())
                        .balanceType(WalletBalanceType.E_MONEY)// todo refactor this
                        .wallet(s.getWalletAccount())
                        .amount(s.getAmount())
                        .runningBalance(s.getAmount().add(walletBalance.getRunningBalance()))
                        .transactionRef(s.getReference())
                        .transaction(s)
                        .build();
            }else{
                newWalletBalance = WalletBalance.builder()
                        .currency(s.getCurrencies())
                        .balanceType(WalletBalanceType.E_MONEY)// todo refactor this
                        .wallet(s.getWalletAccount())
                        .amount(s.getAmount())
                        .runningBalance(walletBalance.getRunningBalance().subtract(s.getAmount()))
                        .transactionRef(s.getReference())
                        .transaction(s)
                        .build();
            }
            walletBalanceList.add(newWalletBalance);
        }

        return walletBalanceRepo.saveAll(walletBalanceList);
    }

    @Override
    public WalletBalance processBalanceChanges(SubTransaction subTransactions) {
        WalletBalance walletBalance= getCurrentBalanceForWalletByCurrencyAndBalanceType(subTransactions.getWalletAccount().getId(),subTransactions.getCurrencies().getId(), WalletBalanceType.valueOf(subTransactions.getPaymentMethod().name()));
        if (walletBalance==null){
            log.info("=======> Could not find the balance");
            // todo implement a fall back mechanism to create the balance and use it
        }
        assert walletBalance != null;
        WalletBalance newWalletBalance;// todo refactor this
        if (subTransactions.getType().equals(TransactionEntryType.CREDIT)){
            newWalletBalance = WalletBalance.builder()
                    .currency(subTransactions.getCurrencies())
                    .balanceType(WalletBalanceType.valueOf(subTransactions.getPaymentMethod().name()))// todo refactor this
                    .wallet(subTransactions.getWalletAccount())
                    .amount(subTransactions.getAmount())
                    .runningBalance(subTransactions.getAmount().add(walletBalance.getRunningBalance()))
                    .transactionRef(subTransactions.getReference())
                    .transaction(subTransactions)
                    .build();
        }else{
            newWalletBalance = WalletBalance.builder()
                    .currency(subTransactions.getCurrencies())
                    .balanceType(WalletBalanceType.valueOf(subTransactions.getPaymentMethod().name()))// todo refactor this
                    .wallet(subTransactions.getWalletAccount())
                    .amount(subTransactions.getAmount())
                    .runningBalance(subTransactions.getAmount().subtract(walletBalance.getRunningBalance()))
                    .transactionRef(subTransactions.getReference())
                    .transaction(subTransactions)
                    .build();
        }
        return walletBalanceRepo.save(newWalletBalance);
    }

    @Override
    public Optional<WalletBalance> getWalletBalanceByTransactionRef(String transactionRef) {
        return walletBalanceRepo.findByTransactionRef(transactionRef);
    }



    @Override
    public Optional<WalletBalance> getLatestWalletBalance(WalletAccount wallet) {
        return walletBalanceRepo.findTopByWalletOrderByDateCreatedDesc(wallet);
    }

}
