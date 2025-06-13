package zw.co.kenac.takeu.backend.controller.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.controller.internal.UserController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DetailedUserResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserRequest;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserResponse;
import zw.co.kenac.takeu.backend.service.internal.UserService;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class UserControllerImpl implements UserController {

    private final UserService userService;

    @Override
    public ResponseEntity<PaginatedResponse<UserResponse>> findAllUsers(int pageNumber, int pageSize, String userType) {
        return ResponseEntity.ok(userService.findAllUsers(pageNumber, pageSize, userType));
    }

    @Override
    public ResponseEntity<GenericResponse<DetailedUserResponse>> findUserById(Long userId) {
        return ResponseEntity.ok(success(userService.findUserById(userId)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> blockUser(Long userId) {
        return ResponseEntity.ok(success(userService.blockUser(userId)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteUserAccount(Long userId) {
        return ResponseEntity.ok(success(userService.deleteUserAccount(userId)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> createUserAccount(UserRequest request) {
        return ResponseEntity.status(201).body(success(userService.createUserAccount(request)));
    }

}
