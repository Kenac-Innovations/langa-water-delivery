package zw.co.kenac.takeu.backend.security.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import zw.co.kenac.takeu.backend.security.response.HttpResponse;

import java.io.IOException;
import java.io.OutputStream;

import static org.springframework.http.HttpStatus.UNAUTHORIZED;
import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;
import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.ACCESS_DENIED_MESSAGE;

@Component
public class JwtAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException exception)
            throws IOException {
        HttpResponse httpResponse = new HttpResponse(
                UNAUTHORIZED.value(),
                UNAUTHORIZED,
                UNAUTHORIZED.getReasonPhrase().toUpperCase(),
                ACCESS_DENIED_MESSAGE
        );

        response.setContentType(APPLICATION_JSON_VALUE);
        response.setStatus(UNAUTHORIZED.value());

        // mapper to convert response to httpResponse
        OutputStream outputStream = response.getOutputStream();
        ObjectMapper mapper = new ObjectMapper();
        mapper.writeValue(outputStream, httpResponse);

        outputStream.flush();
    }
}
