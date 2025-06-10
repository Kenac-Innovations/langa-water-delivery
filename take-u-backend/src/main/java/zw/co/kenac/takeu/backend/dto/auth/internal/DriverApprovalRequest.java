package zw.co.kenac.takeu.backend.dto.auth.internal;

import zw.co.kenac.takeu.backend.model.enumeration.GenericStatus;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
public record DriverApprovalRequest(
        GenericStatus status,
        String reason,
        String approvedBy
) { }
