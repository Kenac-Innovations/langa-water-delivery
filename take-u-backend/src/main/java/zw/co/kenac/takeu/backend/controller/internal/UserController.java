package zw.co.kenac.takeu.backend.controller.internal;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.LoginRequest;
import zw.co.kenac.takeu.backend.dto.auth.internal.DetailedUserResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserRequest;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserResponse;

@RequestMapping("${custom.base.path}/users")
public interface UserController {

    @GetMapping
    ResponseEntity<PaginatedResponse<UserResponse>> findAllUsers(
            @RequestParam int pageNumber,
            @RequestParam int pageSize,
            @RequestParam(defaultValue = "ALL") String userType
    );

    @GetMapping("/{userId}")
    ResponseEntity<GenericResponse<DetailedUserResponse>> findUserById(@PathVariable Long userId);

    @PutMapping("/{userId}/block")
    ResponseEntity<GenericResponse<String>> blockUser(@PathVariable Long userId);

    @DeleteMapping("/{userId}")
    ResponseEntity<GenericResponse<String>> deleteUserAccount(@PathVariable Long userId);

    @PostMapping
    ResponseEntity<GenericResponse<String>> createUserAccount(@RequestBody UserRequest request);

}
