package zw.co.kenac.takeu.backend.walletmodule.dto;

import lombok.Builder;
import lombok.Value;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/26/2025
 */
@Builder
public record WalletBalancesResponseDto(Long id, BigDecimal runningBalance, String transactionRef,
                                        LocalDateTime dateCreated, Long walletId, String currencyCode, Long currencyId,
                                        WalletBalanceType balanceType, WalletAccountType walletAccountType,
                                        WalletOwnerType ownerType) {
}
