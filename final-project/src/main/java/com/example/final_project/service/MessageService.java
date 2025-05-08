package com.example.final_project.service;

import com.example.final_project.dto.MessageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

public interface MessageService {
    ResponseEntity<?> sendMessage(MessageRequest messageRequest, MultipartFile image, int userId);
}
