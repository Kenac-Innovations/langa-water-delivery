package zw.co.kenac.takeu.backend.exception.custom;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */

@ResponseStatus(HttpStatus.PAYMENT_REQUIRED)
public class InsufficientFundsException extends RuntimeException{
    public InsufficientFundsException(String message){
        super(message);
    }
}
