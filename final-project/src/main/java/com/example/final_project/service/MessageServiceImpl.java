package com.example.final_project.service;

import com.example.final_project.cloudinary.CloudinaryService;
import com.example.final_project.controller.MessageSocketController;
import com.example.final_project.dto.AdminMessageRequest;
import com.example.final_project.dto.MessageRequest;
import com.example.final_project.dto.MessageResponse;
import com.example.final_project.entity.Message;
import com.example.final_project.entity.User;
import com.example.final_project.repository.MessageRepository;
import com.example.final_project.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;
    private final MessageRepository messageRepository;
    private final MessageSocketController messageSocketController;

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

        message = messageRepository.save(message);

        MessageResponse messageResponse = MessageResponse.builder()
                .messageId(message.getMessageId())
                .senderId(receiverAdmin.get().getId())
                .receiverId(receiverAdmin.get().getId())
                .content(message.getContent())
                .image(message.getImage())
                .dateTime(message.getDateTime())
                .build();

        // Gửi message lên socket
        messageSocketController.broadcastMessage(messageResponse);

        return ResponseEntity.ok().body("Message sent!");
    }

    @Override
    public ResponseEntity<?> replyMessage(AdminMessageRequest messageRequest, MultipartFile image, int adminId) {
        Optional<User> user = userRepository.findById(adminId);
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

        // Nguoi nhan
        Optional<User> receiver = userRepository.findById(messageRequest.getReceiverId());
        if (receiver.isEmpty()) {
            return ResponseEntity.badRequest().body("Receiver admin not found");
        }

        Message message = Message.builder()
                .sender(user.get())
                .receiver(receiver.get())
                .content(messageRequest.getContent())
                .image(imageUrl)
                .dateTime(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")))
                .build();

        message = messageRepository.save(message);

        MessageResponse messageResponse = MessageResponse.builder()
                .messageId(message.getMessageId())
                .senderId(receiver.get().getId())
                .receiverId(receiver.get().getId())
                .content(message.getContent())
                .image(message.getImage())
                .dateTime(message.getDateTime())
                .build();

        // Gửi message lên socket
        messageSocketController.broadcastMessage(messageResponse);

        return ResponseEntity.ok().body("Message sent!");
    }

    @Override
    public ResponseEntity<?> getConversation(int currentUserId, int withUserId) {
        List<Message> messages = messageRepository.findConversation(currentUserId, withUserId);

        List<MessageResponse> messageResponses = messages.stream()
                .map(message -> MessageResponse.builder()
                        .messageId(message.getMessageId())
                        .senderId(message.getSender().getId())
                        .receiverId(message.getReceiver().getId())
                        .content(message.getContent())
                        .image(message.getImage())
                        .dateTime(message.getDateTime())
                        .build())
                .toList();

        return ResponseEntity.ok().body(messageResponses);
    }
}
