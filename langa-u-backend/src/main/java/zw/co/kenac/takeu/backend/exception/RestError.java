package zw.co.kenac.takeu.backend.exception;

import lombok.Getter;
import lombok.Setter;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

@Setter
@Getter
public class RestError {
    private HttpStatus status;
    private int code;
    private String message;
    private LocalDateTime time;

    public RestError() {
        this.time = LocalDateTime.now();
    }

    public RestError(HttpStatus status, String message) {
        this.status = status;
        this.code = status.value();
        this.message = message;
        this.time = LocalDateTime.now();
    }
}
