package zw.co.kenac.takeu.backend.walletmodule.service;


import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;
import zw.co.kenac.takeu.backend.walletmodule.dto.CurrenciesDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;

import java.util.List;
import java.util.Optional;

public interface CurrencyService {
    Currencies createCurrency (CurrenciesDto currency) ;

    String deleteCurrency( CurrenciesDto currency) ;

    Currencies approveCurrency (CurrenciesDto currency) ;

    Currencies disapproveCurrency( CurrenciesDto currency) ;

    Currencies editCurrency (CurrenciesDto currency) ;

Currencies findCurrencyById(Long id);
    List<Currencies> getAllCurrencies();

    Currencies getCurrencyByName( String name);
    List<Currencies> getCurrenciesByStatus(WalletAccountStatus status);
}
