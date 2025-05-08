package com.example.final_project.controller;

import com.example.final_project.dto.OrderRequest;
import com.example.final_project.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    // Thanh toan
    @PostMapping("/api/v1/orders")
    public ResponseEntity<?> createOrder(
            @RequestBody(required = false) OrderRequest orderRequest,
            Principal principal
            ) {
        return orderService.createOrder(orderRequest, principal);
    }

    // Tracking status của order
    @PutMapping("/api/v1/orders/tracking/{orderId}")
    public ResponseEntity<?> trackOrder(
            @PathVariable int orderId,
            @RequestParam String newStatus
    ) {
        return orderService.trackOrder(orderId, newStatus);
    }

    // Xem list status của order
    @GetMapping("/api/v1/orders/status/{orderId}")
    public ResponseEntity<?> getOrderStatus(@PathVariable int orderId, Principal principal) {
        return orderService.getOrderStatus(orderId, principal);
    }
}
