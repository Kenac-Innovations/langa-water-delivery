package zw.co.kenac.takeu.backend.walletmodule.service;

import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletAccountDto;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletBalancesResponseDto;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletBalance;

import java.math.BigDecimal;
import java.util.List;

/**
 * Created by DylanDzvene
 * Email: dylandzvenetashinga@gmail.com
 * Created on: 4/24/2025
 */
public interface WalletAccountService {
    WalletAccount createWalletAccount(WalletAccountDto walletAccountDto);
    WalletAccount updateWalletAccount(WalletAccountDto walletAccountDto);
    WalletAccount getWalletAccount(Long id);
    WalletAccount getSystemWallet(WalletAccountType walletAccountType);
    WalletAccount getWalletAccountByNumber(String accountNumber);
    WalletAccount getWalletAccountByDriverId(Long ownerId);
    WalletAccount findWalletAccountByDriverId(Long ownerId);
    WalletAccount getWalletAccountByOrganisationId(Long orgId);
    String deleteWalletAccount(Long id);
    BigDecimal getCurrentBalance(Long walletId);
    List<WalletBalancesResponseDto> getAllSystemBalances();
    List<WalletBalancesResponseDto> getAllCurrentBalanceForWallet(Long walletId);// we use this to get all the balance in their currencies and balance types
    List<WalletBalancesResponseDto> getAllCurrentBalanceForWalletByCurrency(Long walletId, String currencyName); // we use this to get both Emoney or Cash balances for a wallet and also by currency
    WalletBalancesResponseDto getAllCurrentBalanceForWalletByCurrencyAndBalanceType(Long walletId, Long currencyId, WalletBalanceType balanceType);// jason we use this to get the balance for example drivers balance for usd e_money
    // Initialize wallets for new drivers and organizations
    WalletAccount initializeDriverWallets(Long driverId);
    WalletBalancesResponseDto getDriverOperationFloatBalance(Long driverId, Long currencyId);
    WalletAccount initializeOrganizationWallets(Long  organizationId);
    List<WalletAccount> initializeSystemWallets();
}
