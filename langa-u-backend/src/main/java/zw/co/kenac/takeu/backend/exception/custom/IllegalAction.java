package zw.co.kenac.takeu.backend.exception.custom;


/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 21/5/2025
 */
public class IllegalAction  extends RuntimeException {
    public IllegalAction(String message) {
        super(message);
    }
}
