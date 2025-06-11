package zw.co.kenac.takeu.backend.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.repository.UserRepository;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserPrincipal loadUserByUsername(String username) throws UsernameNotFoundException {
        UserEntity user = userRepository.findByEmailAddressOrMobileNumber(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not registered. Please consider registering to access our services."));

        return new UserPrincipal(user);
    }
}
