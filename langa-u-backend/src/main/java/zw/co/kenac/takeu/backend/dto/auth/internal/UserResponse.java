package zw.co.kenac.takeu.backend.dto.auth.internal;

import java.time.LocalDateTime;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
public record UserResponse(
        Long userId,
        String firstname,
        String middleName,
        String lastname,
        String mobileNumber,
        String emailAddress,
        String userType,
        LocalDateTime dateJoined,
        boolean enabled,
        boolean accountNonExpired,
        boolean credentialsNonExpired,
        boolean accountNonLocked
) { }
