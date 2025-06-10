package zw.co.kenac.takeu.backend.exception.custom;


/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 2/6/2025
 */
public class DuplicateFoundException extends RuntimeException{
    public DuplicateFoundException(String message){
        super(message);
    }
}
