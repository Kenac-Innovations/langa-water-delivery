package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.DeliveryClientResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryVehicleResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DetailedUserResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserRequest;
import zw.co.kenac.takeu.backend.dto.auth.internal.UserResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.repository.UserRepository;
import zw.co.kenac.takeu.backend.service.internal.UserService;

import java.time.LocalDateTime;
import java.util.List;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final JavaMailService javaMailService;

    @Override
    public PaginatedResponse<UserResponse> findAllUsers(int pageNumber, int pageSize, String userType) {
        Pageable pageable = PageRequest.of(pageNumber, pageSize);

        if (userType.equalsIgnoreCase("ALL")) {
            Page<UserEntity> users = userRepository.findAll(pageable);
            return paginateResponse(users);
        } else {
            Page<UserEntity> users = userRepository.findAllByUserType(pageable, userType);
            return paginateResponse(users);
        }
    }

    @Override
    public DetailedUserResponse findUserById(Long userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        return null;
    }

    @Override
    public String blockUser(Long userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        user.setEnabled(false);
        userRepository.save(user);
        return "User account has been blocked successfully.";
    }

    @Override
    public String deleteUserAccount(Long userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        userRepository.delete(user);
        return "User account has been deleted successfully.";
    }

    @Override
    public String createUserAccount(UserRequest request) {
        UserEntity user = new UserEntity();
        user.setFirstname(request.firstname());
        user.setLastname(request.lastname());
        user.setDateJoined(LocalDateTime.now());
        user.setEmailAddress(request.emailAddress());
        user.setMobileNumber(request.mobileNumber());
        user.setUserPassword(request.userPassword());
        user.setUserType(request.userType());
        user.setEnabled(request.enabled());
        user.setAccountNonExpired(request.accountNonExpired());
        user.setCredentialsNonExpired(request.credentialsNonExpired());
        user.setAccountNonLocked(request.accountNonLocked());

        userRepository.save(user);
        javaMailService.sendAccountCreationInfo(user.getFirstname() + user.getLastname(), user.getEmailAddress(), user.getMobileNumber(), request.userPassword());
        return "Account has been created successfully.";
    }

    public static PaginatedResponse<UserResponse> paginateResponse(Page<UserEntity> page) {
        List<UserEntity> users = page.getContent();

        List<UserResponse> userResponses = users.stream()
                .map(user -> new UserResponse(
                        user.getEntityId(),
                        user.getFirstname(),
                        user.getMiddleName(),
                        user.getLastname(),
                        user.getMobileNumber(),
                        user.getEmailAddress(),
                        user.getUserType(),
                        user.getDateJoined(),
                        user.isEnabled(),
                        user.isAccountNonExpired(),
                        user.isCredentialsNonExpired(),
                        user.isAccountNonLocked()
                ))
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber(),
                page.getSize()
        );

        return new PaginatedResponse<>(userResponses, pagination);
    }
}
