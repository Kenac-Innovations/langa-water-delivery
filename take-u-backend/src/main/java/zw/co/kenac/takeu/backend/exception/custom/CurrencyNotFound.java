package zw.co.kenac.takeu.backend.exception.custom;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/26/2025
 */


public class CurrencyNotFound extends RuntimeException{
    public CurrencyNotFound(String message){
        super(message);
    }
}
