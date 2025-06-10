package zw.co.kenac.takeu.backend.dto.auth.internal;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
public record UserRequest(
        String firstname,
        String middleName,
        String lastname,
        String mobileNumber,
        String emailAddress,
        String userPassword,
        String userType,
        boolean enabled,
        boolean accountNonExpired,
        boolean credentialsNonExpired,
        boolean accountNonLocked
) { }
