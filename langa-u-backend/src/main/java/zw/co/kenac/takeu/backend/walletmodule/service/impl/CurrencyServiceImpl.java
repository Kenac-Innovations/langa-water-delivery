package zw.co.kenac.takeu.backend.walletmodule.service.impl;

import com.sun.jdi.request.DuplicateRequestException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import zw.co.kenac.takeu.backend.exception.custom.CurrencyNotFound;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;
import zw.co.kenac.takeu.backend.walletmodule.dto.CurrenciesDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.repo.CurrenciesRepo;
import zw.co.kenac.takeu.backend.walletmodule.service.CurrencyService;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 04/25/2025
 */
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class CurrencyServiceImpl implements CurrencyService {

    private final CurrenciesRepo currencyRepo;

    @Override
    public Currencies createCurrency(CurrenciesDto currency)  {

        Optional<Currencies> currencyOptional = currencyRepo.findByName(currency.getName());
        if (currencyOptional.isPresent()) {
            throw new DuplicateRequestException("Currency with Id " + currency.getId() + " already exists");
        }
        Currencies currencies = Currencies.builder()
                .alphaCode(currency.getAlphaCode())
                .numericCode(currency.getNumericCode())
                .status(WalletAccountStatus.ACTIVE)
                .name(currency.getName())
                .build();


        return currencyRepo.save(currencies);
    }

    @Override
    public String deleteCurrency(CurrenciesDto currency)  {
        Optional<Currencies> currencyOptional = currencyRepo.findById(currency.getId());
        if (currencyOptional.isEmpty()) {
            throw new CurrencyNotFound("Currency not found");
        }
        Currencies currencyToDelete = currencyOptional.get();
        currencyToDelete.setStatus(WalletAccountStatus.DELETED);
        currencyRepo.save(currencyToDelete);
        return "Success";
    }

    @Override
    public Currencies approveCurrency(CurrenciesDto currency)  {
        Optional<Currencies> currencyOptional = currencyRepo.findByName(currency.getName());
        if (currencyOptional.isEmpty()) {
            throw new CurrencyNotFound("Currency not found w");
        }
       Currencies currencyResponse = currencyOptional.get();
        currencyResponse.setStatus(WalletAccountStatus.ACTIVE);

        return currencyRepo.save(currencyResponse);
    }

    @Override
    public Currencies disapproveCurrency(CurrenciesDto currency)  {
        Optional<Currencies> currencyOptional = currencyRepo.findById(currency.getId());
        if (currencyOptional.isEmpty()) {
            throw new CurrencyNotFound("Currency not found");
        }
        Currencies currencyResponse  = currencyOptional.get();
        currencyResponse.setStatus(WalletAccountStatus.DISAPPROVED);

        return currencyRepo.save(currencyResponse);
    }

    @Override
    public Currencies editCurrency(CurrenciesDto currency)  {
        Optional<Currencies> currencyOptional = currencyRepo.findById(currency.getId());
        if (currencyOptional.isEmpty()) {
            throw new CurrencyNotFound("Currency not found " + currency.getId());
        }
        Currencies currencyResponse = currencyOptional.get();
        BeanUtils.copyProperties(currency, currencyResponse);

        return currencyRepo.save(currencyResponse);
    }

    @Override
    public Currencies findCurrencyById(Long id) {
        Optional<Currencies> currenciesOptional=currencyRepo.findById(id);
        if(currenciesOptional.isEmpty()){
            log.error("======> Currency not found with Id ::{}",id);
            throw new CurrencyNotFound("Currency not found with Id :: "+id);
        }
        return currenciesOptional.get();
    }

    @Override
    public List<Currencies> getAllCurrencies() {
        return currencyRepo.findAll();
    }

    @Override
    public Currencies getCurrencyByName(String name) {
        Optional<Currencies> currencyOptional = currencyRepo.findByName(name);
        if(currencyOptional.isEmpty()){
            log.error("======> Currency not found with name ::{}",name);
            throw new CurrencyNotFound("Currency not found with name :: "+name);
        }
        return currencyOptional.get();

    }

    @Override
    public List<Currencies> getCurrenciesByStatus(WalletAccountStatus status) {
        return currencyRepo.findByStatus(status);
    }
}
