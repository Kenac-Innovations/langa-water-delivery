package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import zw.co.kenac.takeu.backend.event.deliveryEvents.DispatchSettingsChangedEvent;
import zw.co.kenac.takeu.backend.model.waterdelivery.DispatchSettings;
import zw.co.kenac.takeu.backend.repository.DispatchSettingsRepository;

import zw.co.kenac.takeu.backend.service.internal.DispatchSettingsService;
import zw.co.kenac.takeu.backend.service.internal.FirebaseService;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DispatchSettingsServiceImpl implements DispatchSettingsService {

    private final DispatchSettingsRepository dispatchSettingsRepository;
    private final FirebaseService firebaseService;
    private final ApplicationEventPublisher eventPublisher;

    @Override
    public DispatchSettings updateDispatchStatus(boolean status) {
        // Assuming there is only one setting record. Find it or create a new one.
        List<DispatchSettings> settingsList = dispatchSettingsRepository.findAll();
        DispatchSettings settings;
        if (settingsList.isEmpty()) {
            settings = new DispatchSettings();
        } else {
            settings = settingsList.get(0);
        }
        settings.setStatus(status);
        DispatchSettings savedSettings = dispatchSettingsRepository.save(settings);

        // Trigger firebase update
       // firebaseService.updateAutoDispatchStatusInOpenDeliveries(status);
        eventPublisher.publishEvent(new DispatchSettingsChangedEvent(this, status));

        return savedSettings;
    }

    @Override
    public DispatchSettings getDispatchStatus() {
        // Assuming there is only one setting record. Find it or return a default.
        List<DispatchSettings> settingsList = dispatchSettingsRepository.findAll();
        if (settingsList.isEmpty()) {
            DispatchSettings defaultSettings = new DispatchSettings();
            defaultSettings.setStatus(false); // Default to false
            return dispatchSettingsRepository.save(defaultSettings);
        }
        return settingsList.get(0);
    }
} 