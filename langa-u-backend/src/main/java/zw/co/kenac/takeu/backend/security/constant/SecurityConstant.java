package zw.co.kenac.takeu.backend.security.constant;

public class SecurityConstant {
    public final static String UNAUTHORIZED = "You are not allowed to perform this action.";
    public final static String FORBIDDEN = "You are not allowed to perform this action. Please login to access this resource.";
    public final static String UNSUPPORTED_JWT = "Authentication failed. Please try to login again.";
    public  final static String CONFLICT="There was a duplicate request";

    public static final long EXPIRATION_TIME = 2_592_000_000L; // 7 days (one week) expressed in milliseconds
    public static final long REFRESH_TIME = 3_888_000_000L; // 7 days (one week) expressed in milliseconds
    public static final String TOKEN_PREFIX = "Bearer ";
    public static final String AUTH_HEADER = "Authorization";
    public static final String TOKEN_CANNOT_BE_VERIFIED = "Token cannot be verified";
    public static final String COMPANY = "Kenac Computer Systems, Pvt, Ltd";
    public static final String COMPANY_AUDIENCE = "Parcel Delivery Services";
    public static final String AUTHORITIES = "authorities";
    public static final String USER_MISSING = "You need to register to access our services.";
    public static final String FORBIDDEN_MESSAGE = "You need to log in to access this resource.";
    public static final String DISABLED = "Your account is disabled please verify your account or contact your system administrator.";
    public static final String DISABLED_DRIVER = "Your account is please wait your account will be approved soon.";
    public static final String ACCESS_DENIED_MESSAGE = "You do not have permission to access this resource.";
    public static final String OPTIONS_HTTP_STATUS = "OPTIONS";
    public static final String TOKEN_SECRET = "[a-zA-Z0-9._]^+f7re87456rcdf987cr89df745fddsds45ds89";
    public final static String BAD_CREDENTIALS = "Login failed. Please check your username and password.";
    public static final String[] PUBLIC_URLS = {
            "/api/v1/auth/**",
            "/swagger-ui/**",
            "/webjars/**",
            "swagger-ui.html",
            "/v3/api-docs/**",
            "/api/v1/client/auth/**",
            "/api/v1/driver/auth/**",
            "/api/v1/driver/auth/register",
            "/api/v1/wallet/**",
            "/api/v1/auth/login",
            "/api/v1/payments/paynow/callback",
            "/api/v1/auth2/**",
            "/api/v2/**",
    };

}
