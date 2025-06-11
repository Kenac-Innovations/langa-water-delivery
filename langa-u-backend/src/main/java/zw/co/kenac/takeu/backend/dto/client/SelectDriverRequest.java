package zw.co.kenac.takeu.backend.dto.client;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 22/4/2025
 */
public record SelectDriverRequest(
        Long deliveryId,
        Long driverId
) { }
