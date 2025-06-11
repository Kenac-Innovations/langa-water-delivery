-- liquibase formatted sql

-- changeset jaison.chipuka:1744622352343-1
ALTER TABLE ms_client ADD CONSTRAINT uc_ms_client_user_entity UNIQUE (user_entity_id);

-- changeset jaison.chipuka:1744622352343-2
ALTER TABLE ms_driver ADD CONSTRAINT uc_ms_driver_user_entity UNIQUE (user_entity_id);

-- changeset jaison.chipuka:1744622352343-3
ALTER TABLE sp_client_rating ADD CONSTRAINT uc_sp_client_rating_delivery UNIQUE (delivery_id);

-- changeset jaison.chipuka:1744622352343-4
ALTER TABLE sp_driver_rating ADD CONSTRAINT uc_sp_driver_rating_delivery UNIQUE (delivery_id);

-- changeset jaison.chipuka:1744622352343-5
ALTER TABLE ms_client ADD CONSTRAINT FK_MS_CLIENT_ON_USER_ENTITY FOREIGN KEY (user_entity_id) REFERENCES ms_users (entity_id);

-- changeset jaison.chipuka:1744622352343-6
ALTER TABLE sp_driver_rating ADD CONSTRAINT FK_SP_DRIVER_RATING_ON_DELIVERY FOREIGN KEY (delivery_id) REFERENCES ms_deliveries (entity_id);

-- changeset jaison.chipuka:1744622352343-7
ALTER TABLE sp_client_rating ADD CONSTRAINT FK_SP_CLIENT_RATING_ON_DELIVERY FOREIGN KEY (delivery_id) REFERENCES ms_deliveries (entity_id);

-- changeset jaison.chipuka:1744622352343-8
ALTER TABLE ms_vehicle ADD CONSTRAINT FK_MS_VEHICLE_ON_DRIVER_ENTITY FOREIGN KEY (driver_entity_id) REFERENCES ms_driver (entity_id);

-- changeset jaison.chipuka:1744622352343-9
ALTER TABLE ms_vehicle ADD CONSTRAINT FK_MS_VEHICLE_ON_VEHICLE_STATUS FOREIGN KEY (vehicle_status_id) REFERENCES st_vehicle_status (entity_id);

-- changeset jaison.chipuka:1744622352343-10
ALTER TABLE ms_vehicle ADD CONSTRAINT FK_MS_VEHICLE_ON_VEHICLE_TYPE FOREIGN KEY (vehicle_type_id) REFERENCES st_vehicle_type (entity_id);

-- changeset jaison.chipuka:1744622352343-11
ALTER TABLE ms_wallet ADD CONSTRAINT FK_MS_WALLET_ON_USER_ENTITY FOREIGN KEY (user_entity_id) REFERENCES ms_users (entity_id);

-- changeset jaison.chipuka:1744622352343-12
ALTER TABLE sp_drop_offs ADD CONSTRAINT uc_sp_drop_offs_delivery UNIQUE (delivery_id);

-- changeset jaison.chipuka:1744622352343-13
ALTER TABLE sp_pickups ADD CONSTRAINT uc_sp_pickups_delivery UNIQUE (delivery_id);

-- changeset jaison.chipuka:1744622352343-14
ALTER TABLE ms_deliveries ADD CONSTRAINT FK_MS_DELIVERIES_ON_CUSTOMER_ENTITY FOREIGN KEY (customer_entity_id) REFERENCES ms_client (entity_id);

-- changeset jaison.chipuka:1744622352343-15
ALTER TABLE ms_deliveries ADD CONSTRAINT FK_MS_DELIVERIES_ON_DRIVER_ENTITY FOREIGN KEY (driver_entity_id) REFERENCES ms_driver (entity_id);

-- changeset jaison.chipuka:1744622352343-16
ALTER TABLE ms_deliveries ADD CONSTRAINT FK_MS_DELIVERIES_ON_VEHICLE_ENTITY FOREIGN KEY (vehicle_entity_id) REFERENCES ms_vehicle (entity_id);

-- changeset jaison.chipuka:1744622352343-17
ALTER TABLE ms_driver ADD CONSTRAINT FK_MS_DRIVER_ON_USER_ENTITY FOREIGN KEY (user_entity_id) REFERENCES ms_users (entity_id);

-- changeset jaison.chipuka:1744622352343-18
ALTER TABLE ms_wallet ADD CONSTRAINT FK_MS_WALLET_ON_CURRENCY_ENTITY FOREIGN KEY (currency_entity_id) REFERENCES st_currency (entity_id);

-- changeset jaison.chipuka:1744622352343-19
ALTER TABLE password_reset_tokens ADD CONSTRAINT FK_PASSWORD_RESET_TOKENS_ON_USER_ENTITY FOREIGN KEY (user_entity_id) REFERENCES ms_users (entity_id);

-- changeset jaison.chipuka:1744622352343-20
ALTER TABLE sp_available_driver ADD CONSTRAINT FK_SP_AVAILABLE_DRIVER_ON_DELIVERY FOREIGN KEY (delivery_id) REFERENCES ms_deliveries (entity_id);

-- changeset jaison.chipuka:1744622352343-21
ALTER TABLE sp_available_driver ADD CONSTRAINT FK_SP_AVAILABLE_DRIVER_ON_DRIVER FOREIGN KEY (driver_id) REFERENCES ms_driver (entity_id);

-- changeset jaison.chipuka:1744622352343-22
ALTER TABLE sp_drop_offs ADD CONSTRAINT FK_SP_DROP_OFFS_ON_DELIVERY FOREIGN KEY (delivery_id) REFERENCES ms_deliveries (entity_id);

-- changeset jaison.chipuka:1744622352343-23
ALTER TABLE sp_pickups ADD CONSTRAINT FK_SP_PICKUPS_ON_DELIVERY FOREIGN KEY (delivery_id) REFERENCES ms_deliveries (entity_id);

-- changeset jaison.chipuka:1744622352343-24
ALTER TABLE sp_transaction ADD CONSTRAINT FK_SP_TRANSACTION_ON_TRANSACTION FOREIGN KEY (transaction_id) REFERENCES st_currency (entity_id);

-- changeset jaison.chipuka:1744622352343-25
ALTER TABLE ms_users ADD CONSTRAINT unique_email_role UNIQUE (email_address, user_type);
ALTER TABLE ms_users ADD CONSTRAINT unique_mobile_role UNIQUE (mobile_number, user_type);

-- changeset dylan.dzvene:1745759426527-25
ALTER TABLE currencies ADD CONSTRAINT uc_currencies_numericcode UNIQUE (numeric_code);

-- changeset dylan.dzvene:1745759426527-32
ALTER TABLE wallet_account ADD CONSTRAINT uc_walletaccount_accountnumber UNIQUE (account_number);

-- changeset dylan.dzvene:1745759426527-51
ALTER TABLE sub_transaction ADD CONSTRAINT FK_SUBTRANSACTION_ON_CURRENCY FOREIGN KEY (currency_id) REFERENCES currencies (id);

-- changeset dylan.dzvene:1745759426527-52
ALTER TABLE sub_transaction ADD CONSTRAINT FK_SUBTRANSACTION_ON_TRANSACTION FOREIGN KEY (transaction_id) REFERENCES transaction (id);

-- changeset dylan.dzvene:1745759426527-53
ALTER TABLE sub_transaction ADD CONSTRAINT FK_SUBTRANSACTION_ON_WALLETACCOUNT FOREIGN KEY (wallet_account_id) REFERENCES wallet_account (id);

-- changeset dylan.dzvene:1745759426527-54
ALTER TABLE transaction ADD CONSTRAINT FK_TRANSACTION_ON_COMMISSION_WALLET FOREIGN KEY (commission_wallet_id) REFERENCES wallet_account (id);

-- changeset dylan.dzvene:1745759426527-55
ALTER TABLE transaction ADD CONSTRAINT FK_TRANSACTION_ON_CURRENCY FOREIGN KEY (currency_id) REFERENCES currencies (id);

-- changeset dylan.dzvene:1745759426527-56
ALTER TABLE transaction ADD CONSTRAINT FK_TRANSACTION_ON_DESTINATION_WALLET FOREIGN KEY (destination_wallet_id) REFERENCES wallet_account (id);

-- changeset dylan.dzvene:1745759426527-57
ALTER TABLE transaction ADD CONSTRAINT FK_TRANSACTION_ON_SOURCE_WALLET FOREIGN KEY (source_wallet_id) REFERENCES wallet_account (id);

-- changeset dylan.dzvene:1745759426527-58
ALTER TABLE wallet_balance ADD CONSTRAINT FK_WALLETBALANCE_ON_CURRENCY FOREIGN KEY (currency_id) REFERENCES currencies (id);

-- changeset dylan.dzvene:1745759426527-59
ALTER TABLE wallet_balance ADD CONSTRAINT FK_WALLETBALANCE_ON_SUB_TRANSACTION FOREIGN KEY (sub_transaction_id) REFERENCES sub_transaction (id);

-- changeset dylan.dzvene:1745759426527-60
ALTER TABLE wallet_balance ADD CONSTRAINT FK_WALLETBALANCE_ON_WALLET FOREIGN KEY (wallet_id) REFERENCES wallet_account (id);

-- changeset dylan.dzvene:1745589005652-11
ALTER TABLE wallet_balance ADD CONSTRAINT FK_WALLETBALANCE_ON_TRANSACTION FOREIGN KEY (transaction_id) REFERENCES transaction (id);