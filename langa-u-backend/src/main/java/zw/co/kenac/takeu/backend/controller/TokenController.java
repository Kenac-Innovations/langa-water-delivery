package zw.co.kenac.takeu.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 28/5/2025
 */
@RestController
@RequestMapping("${custom.base.path}/token")
public class TokenController {

    @GetMapping("/validate")
    ResponseEntity<Void> validateToken() {
        // This method will be implemented to validate the token
        return ResponseEntity.ok().build();
    }
}
