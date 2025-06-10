package zw.co.kenac.takeu.backend.exception.custom;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.FORBIDDEN)
public class UrlAuthorizationException extends RuntimeException {

    public UrlAuthorizationException() {
        super();
    }

    public UrlAuthorizationException(String message) {
        super(message);
    }

    public UrlAuthorizationException(String message, Throwable cause) {
        super(message, cause);
    }

    public UrlAuthorizationException(Throwable cause) {
        super(cause);
    }

}
