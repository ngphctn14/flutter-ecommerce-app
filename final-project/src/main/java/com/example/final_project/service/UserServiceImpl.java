package com.example.final_project.service;

import com.example.final_project.dto.*;
import com.example.final_project.entity.Role;
import com.example.final_project.entity.User;
import com.example.final_project.entity.UserRole;
import com.example.final_project.repository.RoleRepository;
import com.example.final_project.repository.UserRepository;
import com.example.final_project.repository.UserRoleRepository;
import com.example.final_project.util.JwtTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.Principal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtil jwtTokenUtil;
    private final EmailService emailService;

    @Override
    public ResponseEntity<String> createUser(UserCreate userCreate) {
        // Nếu chưa có role: user -> tạo role
        UserRole userRole = new UserRole();
        Optional<Role> role_user = roleRepository.findByName("USER");
        if (!role_user.isPresent()) {
            Role role = new Role();
            role.setName("USER");
            roleRepository.save(role);

            userRole.setRole(role);
        }
        else {
            userRole.setRole(role_user.get());
        }

        // check email đã tồn tại
        Optional<User> checkUser = userRepository.findByEmail(userCreate.getEmail());
        if (checkUser.isPresent()) {
            return ResponseEntity.badRequest().body("Email has existed!");
        }

        User user = User.builder()
                .fullName(userCreate.getFullName())
                .email(userCreate.getEmail())
                .password(passwordEncoder.encode(userCreate.getPassword()))
                .shippingAddress(userCreate.getShippingAddress())
                .build();


        userRepository.save(user);

        userRole.setUser(user);
        userRoleRepository.save(userRole);
        return ResponseEntity.ok().body("Account user created");

    }

    @Override
    public ResponseEntity<?> login(UserLogin userLogin) {
        // check email
        Optional<User> user = userRepository.findByEmail(userLogin.getEmail());
        if (user.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        boolean isAuthentication = passwordEncoder.matches(userLogin.getPassword(), user.get().getPassword());
        if (!isAuthentication) {
            return ResponseEntity.badRequest().body("Username or password incorrect");
        }

        // ok -> gen token
        final int ONE_DAY_SECONDS = 15 * 60;

        Optional<UserRole> userRole = userRoleRepository.findByUserId(user.get().getId());
        Optional<Role> role = roleRepository.findById(userRole.get().getRole().getId());

        // Chuyển thông tin userlogin -> tokenpayload
        TokenPayload tokenPayload = null;
        if (role.isPresent()) {
            tokenPayload = TokenPayload.builder()
                    .fullName(user.get().getFullName())
                    .userId(user.get().getId())
                    .role(role.get().getName())
                    .build();
        }
        String accessToken = jwtTokenUtil.generateToken(tokenPayload, ONE_DAY_SECONDS);
        // return ve user
        return ResponseEntity.ok().body(LoginResponse.builder()
                .accessToken(accessToken)
                .user(UserResponse.builder()
                        .fullName(user.get().getFullName())
                        .email(user.get().getEmail())
                        .shippingAddress(user.get().getShippingAddress())
                        .build())
                .build());
    }

    @Override
    public ResponseEntity<?> getUserById(int userId) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            UserResponse userResponse = UserResponse.builder()
                    .fullName(user.get().getFullName())
                    .email(user.get().getEmail())
                    .shippingAddress(user.get().getShippingAddress())
                    .build();

            return ResponseEntity.ok().body(userResponse);
        }
        return ResponseEntity.badRequest().body("User must be login");
    }

    @Override
    public ResponseEntity<String> changePassword(int userId, ChangePasswordRequest changePasswordRequest) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        if (!passwordEncoder.matches(changePasswordRequest.getOldPassword(), user.get().getPassword())) {
            return ResponseEntity.badRequest().body("Old password is incorrect");
        }

        user.get().setPassword(passwordEncoder.encode(changePasswordRequest.getNewPassword()));
        userRepository.save(user.get());

        return ResponseEntity.ok().body("Password changed");
    }

    @Override
    public ResponseEntity<?> recoveryPassword(String email) {
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        // Sinh mã OTP (6 số)
        String otp = String.format("%06d", new Random().nextInt(1000000));

        // Lưu thông tin OTP vào user
        user.get().setResetOtp(otp);
        user.get().setResetOtpExpiryDate(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusMinutes(5));
        userRepository.save(user.get());

        // Gửi email thông tin báo
        emailService.sendOTPEmailRecoveryPassword(user.get().getEmail(), otp);

        return ResponseEntity.ok("Mã OTP đã được gửi đến email của bạn.");
    }

    @Override
    public ResponseEntity<?> resetPassword(ConfirmOTPRequest confirmOTPRequest) {
        // Check email
        Optional<User> user = userRepository.findByEmail(confirmOTPRequest.getEmail());
        if (user.isEmpty()) {
            return ResponseEntity.badRequest().body("Email not found");
        }

        // Check OTP
        if (!confirmOTPRequest.getOtp().equals(user.get().getResetOtp())) {
            return ResponseEntity.badRequest().body("OTP is incorrect");
        }

        // Check thời hạn mã otp
        if (user.get().getResetOtpExpiryDate().isBefore(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")))) {
            return ResponseEntity.badRequest().body("OTP expired");
        }


        // Set password moi
        user.get().setPassword(passwordEncoder.encode(confirmOTPRequest.getPassword()));

        // Xoa ma otp
        user.get().setResetOtp(null);
        user.get().setResetOtpExpiryDate(null);
        userRepository.save(user.get());

        return ResponseEntity.ok().body("Reset password successfully");
    }
}
