package zw.co.kenac.takeu.backend.service.internal;


import zw.co.kenac.takeu.backend.model.waterdelivery.DispatchSettings;

public interface DispatchSettingsService {
    DispatchSettings updateDispatchStatus(boolean status);
    DispatchSettings getDispatchStatus();
} 