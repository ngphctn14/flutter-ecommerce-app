package com.example.final_project.repository;

import com.example.final_project.cloudinary.CloudinaryService;
import com.example.final_project.dto.MessageRequest;
import com.example.final_project.entity.Message;
import com.example.final_project.entity.User;
import com.example.final_project.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;
    private final MessageRepository messageRepository;

    @Override
    public ResponseEntity<?> sendMessage(MessageRequest messageRequest, MultipartFile image, int userId) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        // Check tin nhắn có rỗng hay không
        if ((messageRequest.getContent() == null || messageRequest.getContent().isBlank()) && image == null) {
            return ResponseEntity.badRequest().body("Content or image must be provided");
        }

        String imageUrl = "";
        if (image != null) {
            try {
                imageUrl = cloudinaryService.uploadImage(image);
            } catch (IOException e) {
                return ResponseEntity.badRequest().body("Upload image failed");
            }
        }

        // admin_id = 2
        Optional<User> receiverAdmin = userRepository.findById(2);
        if (receiverAdmin.isEmpty()) {
            return ResponseEntity.badRequest().body("Receiver admin not found");
        }

        // Gửi message vào database
        Message message = Message.builder()
                .sender(user.get())
                .receiver(receiverAdmin.get())
                .content(messageRequest.getContent())
                .image(imageUrl)
                .dateTime(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")))
                .build();

        messageRepository.save(message);
        return ResponseEntity.ok().body("Message sent!");
    }
}
