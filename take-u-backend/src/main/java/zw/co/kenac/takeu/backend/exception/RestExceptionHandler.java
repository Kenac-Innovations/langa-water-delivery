package zw.co.kenac.takeu.backend.exception;

import com.sun.jdi.request.DuplicateRequestException;
import io.swagger.v3.oas.annotations.Hidden;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.exception.custom.*;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.context.request.WebRequest;
import jakarta.servlet.ServletException;

import java.util.HashMap;
import java.util.Map;

import static org.springframework.core.Ordered.HIGHEST_PRECEDENCE;
import static zw.co.kenac.takeu.backend.constant.AppConstant.CONFLICT;
import static zw.co.kenac.takeu.backend.constant.AppConstant.REQUEST_SIZE_EX;
import static zw.co.kenac.takeu.backend.dto.GenericResponse.exception;
import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.*;

@Hidden
@RestControllerAdvice
@Order(HIGHEST_PRECEDENCE)
public class RestExceptionHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(RestExceptionHandler.class);

    // ADDED: Handle validation errors (invalid request body fields)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<GenericResponse<RestError>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        LOGGER.info("Validation error: {}", ex.getMessage());

        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });

        RestError error = new RestError(HttpStatus.BAD_REQUEST, "Validation error: Please check your input data");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    // ADDED: Handle JSON parsing errors (malformed JSON)
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<GenericResponse<RestError>> handleJsonErrors(HttpMessageNotReadableException ex) {
        LOGGER.info("Invalid request format: {}", ex.getMessage());

        RestError error = new RestError(HttpStatus.BAD_REQUEST, "Invalid request format. Please check your JSON syntax.");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    // Handle 404 errors - endpoint not found
    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<GenericResponse<RestError>> handleNoHandlerFound(NoHandlerFoundException ex) {
        LOGGER.info("Endpoint not found: {}", ex.getMessage());
        RestError error = new RestError(HttpStatus.NOT_FOUND, "The requested endpoint does not exist: " + ex.getRequestURL());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(exception(error));
    }

    // Handle unsupported HTTP method
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<GenericResponse<RestError>> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex) {
        LOGGER.info("Method not supported: {}", ex.getMessage());
        RestError error = new RestError(HttpStatus.METHOD_NOT_ALLOWED, 
            "The " + ex.getMethod() + " method is not supported for this endpoint. Supported methods: " + ex.getSupportedHttpMethods());
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(exception(error));
    }

    // Handle missing required parameters
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<GenericResponse<RestError>> handleMissingParams(MissingServletRequestParameterException ex) {
        LOGGER.info("Missing parameter: {}", ex.getMessage());
        RestError error = new RestError(HttpStatus.BAD_REQUEST, "Required parameter is missing: " + ex.getParameterName());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    // Handle type mismatch for parameters
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<GenericResponse<RestError>> handleTypeMismatch(MethodArgumentTypeMismatchException ex) {
        LOGGER.info("Type mismatch: {}", ex.getMessage());
        String message = "Parameter '" + ex.getName() + "' should be of type " + ex.getRequiredType().getSimpleName();
        RestError error = new RestError(HttpStatus.BAD_REQUEST, message);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    @ExceptionHandler(DuplicateFoundException.class)
    public ResponseEntity<GenericResponse<RestError>> handleDuplicateFound(DuplicateFoundException ex) {

        RestError error = new RestError(HttpStatus.BAD_REQUEST, ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    // Handle unsupported media types
    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<GenericResponse<RestError>> handleUnsupportedMediaType(HttpMediaTypeNotSupportedException ex) {
        LOGGER.info("Unsupported media type: {}", ex.getMessage());
        StringBuilder supportedTypes = new StringBuilder();
        ex.getSupportedMediaTypes().forEach(t -> supportedTypes.append(t).append(", "));
        
        RestError error = new RestError(HttpStatus.UNSUPPORTED_MEDIA_TYPE, 
            "Unsupported media type. Supported types: " + supportedTypes.substring(0, supportedTypes.length() - 2));
        return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE).body(exception(error));
    }

    // Generic servlet exceptions that might be related to request processing
    @ExceptionHandler(ServletException.class)
    public ResponseEntity<GenericResponse<RestError>> handleServletException(ServletException ex) {
        LOGGER.error("Servlet exception: {}", ex.getMessage(), ex);
        RestError error = new RestError(HttpStatus.BAD_REQUEST, "Invalid request: " + ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<GenericResponse<RestError>> resourceNotFound(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.NOT_FOUND, exception.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(exception(error));
    }

    @ExceptionHandler(ForbiddenException.class)
    public ResponseEntity<GenericResponse<RestError>> forbidden(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, FORBIDDEN);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }
    @ExceptionHandler(IllegalAction.class)
    public ResponseEntity<GenericResponse<RestError>> forbidden(IllegalAction exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, exception.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }


    @ExceptionHandler(DisabledException.class)
    public ResponseEntity<GenericResponse<RestError>> disabled(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, DISABLED);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    @ExceptionHandler(InsufficientFundsException.class)
    public ResponseEntity<GenericResponse<RestError>> insufficientFunds(InsufficientFundsException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.PAYMENT_REQUIRED, exception.getMessage() != null ? exception.getMessage() : "Insufficient funds");
        return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(exception(error));
    }

    @ExceptionHandler(DuplicateRequestException.class)
    public ResponseEntity<GenericResponse<RestError>> duplicate(DuplicateRequestException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.CONFLICT, CONFLICT);
        return ResponseEntity.status(HttpStatus.CONFLICT).body(exception(error));
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<GenericResponse<RestError>> authenticationEx(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, FORBIDDEN);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    @ExceptionHandler(CurrencyNotFound.class)
    public ResponseEntity<GenericResponse<RestError>> currencyNotFound(CurrencyNotFound exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.NOT_FOUND, exception.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(exception(error));
    }

    /*@ExceptionHandler(UnsupportedJwtException.class)
    public ResponseEntity<GenericResponse<RestError>> unsupportedJwt(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, UNSUPPORTED_JWT);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    @ExceptionHandler(JwtException.class)
    public ResponseEntity<GenericResponse<RestError>> jwtEx(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, UNSUPPORTED_JWT);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    @ExceptionHandler(ExpiredJwtException.class)
    public ResponseEntity<GenericResponse<RestError>> expiredJwt(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, UNSUPPORTED_JWT);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    @ExceptionHandler(InvalidKeyException.class)
    public ResponseEntity<GenericResponse<RestError>> invalidKey(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, UNSUPPORTED_JWT);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }*/

    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<GenericResponse<RestError>> unauthorized(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.UNAUTHORIZED, UNAUTHORIZED);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(exception(error));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<GenericResponse<RestError>> accessDenied(Exception exception) {
        LOGGER.error(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.UNAUTHORIZED, UNAUTHORIZED);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(exception(error));
    }
    @ExceptionHandler(IncorrectOtp.class)
    public ResponseEntity<GenericResponse<RestError>> incorrectOtp(IncorrectOtp exception) {
        LOGGER.error(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.BAD_REQUEST, exception.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<GenericResponse<RestError>> badCredentials(Exception exception) {
        LOGGER.error(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.BAD_REQUEST, BAD_CREDENTIALS);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    @ExceptionHandler(FileRequiredException.class)
    public ResponseEntity<GenericResponse<RestError>> fileMissing(Exception exception) {
        LOGGER.error(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.BAD_REQUEST, exception.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }
    @ExceptionHandler(DriverProposalLimitExceededException.class)
    public ResponseEntity<GenericResponse<RestError>> fileMissing(DriverProposalLimitExceededException exception) {
        LOGGER.error(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.BAD_REQUEST, exception.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception(error));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<GenericResponse<RestError>> constraint(Exception exception) {
        LOGGER.error(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.CONFLICT, CONFLICT);
        return ResponseEntity.status(HttpStatus.CONFLICT).body(exception(error));
    }

    @ExceptionHandler(UrlAuthorizationException.class)
    public ResponseEntity<GenericResponse<RestError>> urlAuthorization(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, exception.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<GenericResponse<RestError>> maxFileSize(RuntimeException exception) {
        LOGGER.info(exception.getMessage(), exception);
        RestError error = new RestError(HttpStatus.FORBIDDEN, REQUEST_SIZE_EX);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exception(error));
    }

    // Global catch-all exception handler for any unhandled exceptions
    @ExceptionHandler(Exception.class)
    public ResponseEntity<GenericResponse<RestError>> handleGlobalException(Exception ex) {
        LOGGER.error("Unhandled exception occurred: {}", ex.getMessage(), ex);
        RestError error = new RestError(HttpStatus.INTERNAL_SERVER_ERROR, "An unexpected error occurred: " + ex.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(exception(error));
    }
}
