package com.example.final_project.controller;

import com.example.final_project.dto.CustomUserDetails;
import com.example.final_project.dto.MessageRequest;
import com.example.final_project.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
public class MessageController {
    private final MessageService messageService;

    // API gửi tin nhắn từ user gửi cho admin
    @PostMapping("/api/v1/message/send")
    public ResponseEntity<?> sendMessage(
        @RequestPart("message") MessageRequest messageRequest,
        @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        int userId = userDetails.getId();
        return messageService.sendMessage(messageRequest, image, userId);
    }

}
