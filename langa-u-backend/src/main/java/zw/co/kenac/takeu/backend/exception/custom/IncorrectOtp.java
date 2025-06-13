package zw.co.kenac.takeu.backend.exception.custom;


/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 13/5/2025
 */
public class IncorrectOtp extends RuntimeException {
    public IncorrectOtp(String message) {
        super(message);
    }
}
