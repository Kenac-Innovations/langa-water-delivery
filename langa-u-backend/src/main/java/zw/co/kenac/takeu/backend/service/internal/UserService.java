package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DetailedUserResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserRequest;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserResponse;

public interface UserService {

    PaginatedResponse<UserResponse> findAllUsers(int pageNumber, int pageSize, String userType);

    DetailedUserResponse findUserById(Long userId);

    String blockUser(Long userId);

    String deleteUserAccount(Long userId);

    String createUserAccount(UserRequest request);

}
