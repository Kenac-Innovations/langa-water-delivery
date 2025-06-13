package zw.co.kenac.takeu.backend.controller.wallet;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletAccountDto;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletBalancesResponseDto;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;

import java.util.List;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */
@RestController
@RequestMapping(value = "/api/v1/wallet")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Wallet Management Controller", description = "Endpoints for Wallet Management Functionality")

public class WalletAccountController {
    private final WalletAccountService walletAccountService;


    @Operation(summary = "Initially creating Driver wallet")
    @PostMapping("/initialize-driver")
    public ResponseEntity<GenericResponse<WalletAccount>> initialWalletForInd(@RequestParam Long driverId) {
        log.info("========> Create Wallet API for driver {}", driverId);
        WalletAccount response = walletAccountService.initializeDriverWallets(driverId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Initialize system wallets")
    @PostMapping("/initialize-system-wallets")
    public ResponseEntity<GenericResponse<List< WalletAccount>>> initializeSystemWallets() {
        log.info("========> Create Wallet API for System ");
       List <WalletAccount> response = walletAccountService.initializeSystemWallets();
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Initially creating Organisation wallet")
    @PostMapping("/initialize-org")
    public ResponseEntity<GenericResponse<WalletAccount>> initialWalletForOrganization(@RequestParam Long orgId) {
        log.info("========> Create Wallet API for For Org {}", orgId);
        WalletAccount response = walletAccountService.initializeOrganizationWallets(orgId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Initially creating System wallet")
    @PostMapping("/initialize-system")
    public ResponseEntity<GenericResponse<WalletAccount>> initialWalletForSystem(@RequestParam Long driverId) {
        log.info("========> Create Wallet API for System {}", driverId);
        WalletAccount response = walletAccountService.initializeDriverWallets(driverId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Create a new wallet account")
    @PostMapping
    public ResponseEntity<GenericResponse<WalletAccount>> createWalletAccount(@RequestBody WalletAccountDto walletAccountDto) {
        log.info("========> Create Wallet Account API request {}", walletAccountDto);
        WalletAccount response = walletAccountService.createWalletAccount(walletAccountDto);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Update an existing wallet account")
    @PutMapping
    public ResponseEntity<GenericResponse<WalletAccount>> updateWalletAccount(@RequestBody WalletAccountDto walletAccountDto) {
        log.info("========> Update Wallet Account API request {}", walletAccountDto);
        WalletAccount response = walletAccountService.updateWalletAccount(walletAccountDto);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get wallet account by ID")
    @GetMapping("/{id}")
    public ResponseEntity<GenericResponse<WalletAccount>> getWalletAccount(@PathVariable Long id) {
        log.info("========> Get Wallet Account API for ID {}", id);
        WalletAccount response = walletAccountService.getWalletAccount(id);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get wallet account by account number")
    @GetMapping("/account-number/{accountNumber}")
    public ResponseEntity<GenericResponse<WalletAccount>> getWalletAccountByNumber(@PathVariable String accountNumber) {
        log.info("========> Get Wallet Account API for account number {}", accountNumber);
        WalletAccount response = walletAccountService.getWalletAccountByNumber(accountNumber);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Get wallet accounts by owner ID and type")
    @GetMapping("/owner")
    public ResponseEntity<GenericResponse<WalletAccount>> getWalletAccountsByOwner(
            @RequestParam Long ownerId,
            @RequestParam WalletOwnerType ownerType) {
        log.info("========> Get Wallet Accounts API for owner ID {} and type {}", ownerId, ownerType);
        WalletAccount response = walletAccountService.getWalletAccountByDriverId(ownerId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Get system wallet by wallet account type")
    @GetMapping("/system-wallet")
    public ResponseEntity<GenericResponse<WalletAccount>> getSystemWallet(@RequestParam WalletAccountType walletAccountType) {
        log.info("========> Get System Wallet API request for wallet account type {}", walletAccountType);
        WalletAccount response = walletAccountService.getSystemWallet(walletAccountType);
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Get all system wallet balances")
    @GetMapping("/system-wallet/balances")
    public ResponseEntity<GenericResponse<List<WalletBalancesResponseDto>>> getAllSystemBalances() {
        log.info("========> Get All System Wallet Balances API request");
        List<WalletBalancesResponseDto> response = walletAccountService.getAllSystemBalances();
        return ResponseEntity.ok(GenericResponse.success(response));
    }
    @Operation(summary = "Get driver's operation float balance")
    @GetMapping("/driver/{driverId}/operation-float")
    public ResponseEntity<GenericResponse<WalletBalancesResponseDto>> getDriverOperationFloatBalance(
            @PathVariable Long driverId,
            @RequestParam Long currencyId
            ) {
        log.info("========> Get Driver Operation Float Balance API request for driverId: {}, currencyId: {}", driverId, currencyId);
        WalletBalancesResponseDto response = walletAccountService.getDriverOperationFloatBalance(driverId, currencyId);
        return ResponseEntity.ok(GenericResponse.success(response));
    }

    @Operation(summary = "Delete a wallet account")
    @DeleteMapping("/{id}")
    public ResponseEntity<GenericResponse<String>> deleteWalletAccount(@PathVariable Long id) {
        log.info("========> Delete Wallet Account API for ID {}", id);
        String response = walletAccountService.deleteWalletAccount(id);
        return ResponseEntity.ok(GenericResponse.success(response));
    }


    @Operation(summary = "Get all current balances for a wallet")
    @GetMapping("/balances/{walletId}")
    public ResponseEntity<GenericResponse<List<WalletBalancesResponseDto>>> getAllCurrentBalanceForWallet(@PathVariable Long walletId) {
        log.info("========> Get All Current Balances API for wallet ID {}", walletId);
        List<WalletBalancesResponseDto> balances = walletAccountService.getAllCurrentBalanceForWallet(walletId);
        return ResponseEntity.ok(GenericResponse.success(balances));
    }

    @Operation(summary = "Get all current balances for a wallet by currency")
    @GetMapping("/balances/{walletId}/currency/{currencyName}")
    public ResponseEntity<GenericResponse<List<WalletBalancesResponseDto>>> getAllCurrentBalanceForWalletByCurrency(
            @PathVariable Long walletId,
            @PathVariable String currencyName) {
        log.info("========> Get All Current Balances API for wallet ID {} and currency ID {}", walletId, currencyName.toUpperCase());
        List<WalletBalancesResponseDto> balances = walletAccountService.getAllCurrentBalanceForWalletByCurrency(walletId, currencyName.toUpperCase());
        return ResponseEntity.ok(GenericResponse.success(balances));
    }

    @Operation(summary = "Get current balance for a wallet by currency and balance type")
    @GetMapping("/balances/{walletId}/currency/{currencyId}/type/{balanceType}")
    public ResponseEntity<GenericResponse<WalletBalancesResponseDto>> getAllCurrentBalanceForWalletByCurrencyAndBalanceType(
            @PathVariable Long walletId,
            @PathVariable Long currencyId,
            @PathVariable WalletBalanceType balanceType) {
        log.info("========> Get Current Balance API for wallet ID {}, currency ID {}, and balance type {}",
                walletId, currencyId, balanceType);
        WalletBalancesResponseDto balance = walletAccountService.getAllCurrentBalanceForWalletByCurrencyAndBalanceType(
                walletId, currencyId, balanceType);
        return ResponseEntity.ok(GenericResponse.success(balance));
    }

}
