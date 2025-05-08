package com.example.final_project.service;

import com.example.final_project.dto.OrderRequest;
import org.springframework.http.ResponseEntity;

import java.security.Principal;

public interface OrderService {
    ResponseEntity<?> createOrder(OrderRequest orderRequest, Principal principal);

    ResponseEntity<?> trackOrder(int orderId, String newStatus);

    ResponseEntity<?> getOrderStatus(int orderId, Principal principal);
}
