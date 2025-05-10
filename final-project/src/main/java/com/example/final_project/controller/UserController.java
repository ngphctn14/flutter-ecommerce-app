package com.example.final_project.controller;

import com.example.final_project.dto.*;
import com.example.final_project.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

// Rest: RestfulAPI
@RestController
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping("/api/v1/register/user/")
    public ResponseEntity<String> createUser(@RequestBody UserCreate userCreate) {
        return userService.createUser(userCreate);
    }

    @PostMapping("/api/v1/login")
    public ResponseEntity<?> login(@RequestBody UserLogin userLogin) {
        return userService.login(userLogin);
    }

    // Login firebase
//    @PostMapping("/api/v1/firebase-login")
//    public ResponseEntity<?> firebaseLogin(@RequestHeader("Authorization") String bearerToken) {
//        String idToken = bearerToken.substring(7);
//        return userService.firebaseLogin(idToken);
//    }

    @GetMapping("/api/v1/profile/user")
    public ResponseEntity<?> getUserById() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        int userId = userDetails.getId();
        return userService.getUserById(userId);
    }

    // thay doi password
    @PostMapping("/api/v1/change-password/user")
    public ResponseEntity<String> changePassword(@RequestBody ChangePasswordRequest changePasswordRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        int userId = userDetails.getId();
        return userService.changePassword(userId,  changePasswordRequest);
    }

    // Recovery password
    // Send mã OTP qua email
    @PostMapping("/api/v1/recovery/password")
    public ResponseEntity<?> recoveryPassword(@RequestParam String email) {
        return userService.recoveryPassword(email);
    }

    /**
     * Sau khi có mã otp, nhập email, mật khẩu mới, otp để xác thực
     */

    @PostMapping("/api/v1/reset/password")
    public ResponseEntity<?> resetPassword(@RequestBody ConfirmOTPRequest confirmOTPRequest) {
        return userService.resetPassword(confirmOTPRequest);
    }

}
