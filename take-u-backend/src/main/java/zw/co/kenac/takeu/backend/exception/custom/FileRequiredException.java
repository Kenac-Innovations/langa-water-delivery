package zw.co.kenac.takeu.backend.exception.custom;


import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class FileRequiredException extends RuntimeException {

    public FileRequiredException() {
        super();
    }

    public FileRequiredException(String message) {
        super(message);
    }

    public FileRequiredException(String message, Throwable cause) {
        super(message, cause);
    }

    public FileRequiredException(Throwable cause) {
        super(cause);
    }
}
