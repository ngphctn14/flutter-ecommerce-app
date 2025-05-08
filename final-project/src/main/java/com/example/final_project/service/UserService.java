package com.example.final_project.service;

import com.example.final_project.dto.*;
import org.springframework.http.ResponseEntity;

import java.security.Principal;

public interface UserService {
    ResponseEntity<String> createUser(UserCreate userCreate);

    ResponseEntity<?> login(UserLogin userLogin);

    ResponseEntity<?> getUserById(int userId);

    ResponseEntity<String> changePassword(int userId, ChangePasswordRequest changePasswordRequest);

    ResponseEntity<?> recoveryPassword(String email);

    ResponseEntity<?> resetPassword(ConfirmOTPRequest confirmOTPRequest);
}
