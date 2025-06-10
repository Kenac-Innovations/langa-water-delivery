package zw.co.kenac.takeu.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenericResponse<T> {

    private boolean success;
    private String message;
    private T data;

    public static <T> GenericResponse<T> empty() {
        return GenericResponse.<T>builder()
                .message("Empty!")
                .success(true)
                .build();
    }

    public static <T> GenericResponse<T> success(T data) {
        return GenericResponse.<T>builder()
                .message("Success!")
                .success(true)
                .data(data)
                .build();
    }

    public static <T> GenericResponse<T> error() {
        return GenericResponse.<T>builder()
                .message("Error!")
                .success(false)
                .build();
    }

    public static <T> GenericResponse<T> exception(T data) {
        return GenericResponse.<T>builder()
                .message("Exception!")
                .success(false)
                .data(data)
                .build();
    }

}
