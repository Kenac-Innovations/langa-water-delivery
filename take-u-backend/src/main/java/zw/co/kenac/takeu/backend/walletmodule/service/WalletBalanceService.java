package zw.co.kenac.takeu.backend.walletmodule.service;

import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;
import zw.co.kenac.takeu.backend.walletmodule.models.SubTransaction;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletBalance;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dylandzvenetashinga@gmail.com
 * Created on: 4/24/2025
 */
public interface WalletBalanceService {


        WalletBalance createWalletBalance(WalletAccount wallet, long amount, String transactionRef, Transaction transaction);


        List<WalletBalance>  getCurrentAllBalanceForWallet(WalletAccount wallet);

        List<WalletBalance> getAllCurrentBalanceForWalletByCurrency(Long walletId,Long currencyId);
        WalletBalance getCurrentBalanceForWalletByCurrencyAndBalanceType(Long walletId, Long currencyId, WalletBalanceType balanceType);
        List<WalletBalance> getWalletBalanceHistory(WalletAccount wallet);
        List<WalletBalance> processBalanceChanges(List<SubTransaction> subTransactions);
        WalletBalance processBalanceChanges(SubTransaction subTransactions);
        Optional<WalletBalance> getWalletBalanceByTransactionRef(String transactionRef);



        Optional<WalletBalance> getLatestWalletBalance(WalletAccount wallet);

}
