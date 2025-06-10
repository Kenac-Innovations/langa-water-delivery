package zw.co.kenac.takeu.backend.walletmodule.service.impl;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletCurrency;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletAccountDto;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;

import java.util.List;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */


@Service
@RequiredArgsConstructor
public class SystemInitializationService {
    private final WalletAccountService walletAccountService;

//   @PostConstruct // todo to fix this to  THIS BREAKS BECAUSE OF NO CURRENCIES AVALIABLE INIALLY
    public void initializeSystemWallets() {
        // todo  Create Master User for TakeU
        List<WalletAccount> walletAccountList = walletAccountService.initializeSystemWallets();

    }


}