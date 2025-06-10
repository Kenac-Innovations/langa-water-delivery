package zw.co.kenac.takeu.backend.security.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import zw.co.kenac.takeu.backend.security.provider.JwtTokenProvider;

import java.io.IOException;
import java.util.List;

import static org.springframework.http.HttpHeaders.AUTHORIZATION;
import static org.springframework.http.HttpStatus.OK;
import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.OPTIONS_HTTP_STATUS;
import static zw.co.kenac.takeu.backend.security.constant.SecurityConstant.TOKEN_PREFIX;

@Component
@AllArgsConstructor
@Slf4j
public class AuthorizationFilter extends OncePerRequestFilter {
    private JwtTokenProvider jwtTokenProvider;

//    @Override
//    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
//        if (request.getMethod().equalsIgnoreCase(OPTIONS_HTTP_STATUS)) {
//            // check if request method is options (because opt it's send before any request
//            // we should do nothing if req method is options
//            response.setStatus(OK.value());
//        } else {
//            String authorizationHeader = request.getHeader(AUTHORIZATION);
//            if (authorizationHeader == null || !authorizationHeader.startsWith(TOKEN_PREFIX)) {
//                filterChain.doFilter(request, response);
//                return;
//            }
//
//            // retrieve just the token by removing the bearer prefix
//            String token = authorizationHeader.substring(TOKEN_PREFIX.length());
//            String username = jwtTokenProvider.getSubject(token);
//
//            if (jwtTokenProvider.isTokenValid(username, token)
//                    && SecurityContextHolder.getContext().getAuthentication() == null)
//            {
//                List<GrantedAuthority> authorities = jwtTokenProvider.getAuthorities(token);
//                Authentication authentication = jwtTokenProvider.getAuthentication(username, authorities, request);
//                SecurityContextHolder.getContext().setAuthentication(authentication);
//            } else {
//                SecurityContextHolder.clearContext();
//            }
//        }
//        filterChain.doFilter(request, response);
//    }
@Override
protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
    if (request.getMethod().equalsIgnoreCase(OPTIONS_HTTP_STATUS)) {
        // check if request method is options (because opt it's send before any request
        // we should do nothing if req method is options
        response.setStatus(OK.value());
    } else {
        String authorizationHeader = request.getHeader(AUTHORIZATION);
        if (authorizationHeader == null || !authorizationHeader.startsWith(TOKEN_PREFIX)) {
            logger.info("No authorization header or invalid prefix for request: " + request.getRequestURI());
            filterChain.doFilter(request, response);
            return;
        }

        // retrieve just the token by removing the bearer prefix
        String token = authorizationHeader.substring(TOKEN_PREFIX.length());
        String username = jwtTokenProvider.getSubject(token);

        logger.info("Processing token for user: " + username + " on URI: " + request.getRequestURI());

        if (jwtTokenProvider.isTokenValid(username, token)
                && SecurityContextHolder.getContext().getAuthentication() == null)
        {
            List<GrantedAuthority> authorities = jwtTokenProvider.getAuthorities(token);
            logger.info("Token validated with authorities: " + authorities);
            Authentication authentication = jwtTokenProvider.getAuthentication(username, authorities, request);
            SecurityContextHolder.getContext().setAuthentication(authentication);
        } else {
            log.warn("Invalid token or authentication already exists for user: " + username);
            // Instead of just clearing context, let the request continue to be properly rejected
            // by the authentication entry point
            SecurityContextHolder.clearContext();
        }
    }
    filterChain.doFilter(request, response);
}
}

