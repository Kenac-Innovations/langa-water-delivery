package zw.co.kenac.takeu.backend.security.filter;


import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;
import zw.co.kenac.takeu.backend.security.response.HttpResponse;
import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;
import javax.naming.AuthenticationException;
import java.io.IOException;
import java.io.OutputStream;

import static org.springframework.http.HttpStatus.FORBIDDEN;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 14/5/2025
 */
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

//    @Override
//    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception)
//            throws IOException {
//        // This will only be called for authentication/authorization failures
//        HttpResponse httpResponse = new HttpResponse(
//                FORBIDDEN.value(),
//                FORBIDDEN,
//                FORBIDDEN.getReasonPhrase().toUpperCase(),
//                "Authentication failed: " + exception.getMessage());
//
//        response.setContentType(APPLICATION_JSON_VALUE);
//        response.setStatus(FORBIDDEN.value());
//
//        OutputStream outputStream = response.getOutputStream();
//        ObjectMapper mapper = new ObjectMapper();
//        mapper.writeValue(outputStream, httpResponse);
//
//        outputStream.flush();
//    }

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, org.springframework.security.core.AuthenticationException authException) throws IOException, ServletException {
        // This will only be called for authentication/authorization failures
        HttpResponse httpResponse = new HttpResponse(
                FORBIDDEN.value(),
                FORBIDDEN,
                FORBIDDEN.getReasonPhrase().toUpperCase(),
                "Authentication failed: " + authException.getMessage());

        response.setContentType(APPLICATION_JSON_VALUE);
        response.setStatus(FORBIDDEN.value());

        OutputStream outputStream = response.getOutputStream();
        ObjectMapper mapper = new ObjectMapper();
        mapper.writeValue(outputStream, httpResponse);

        outputStream.flush();
    }
}