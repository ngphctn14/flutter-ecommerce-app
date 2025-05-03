package com.example.final_project.service;

import com.example.final_project.dto.CustomUserDetails;
import com.example.final_project.dto.OrderRequest;
import com.example.final_project.entity.*;
import com.example.final_project.repository.*;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.security.Principal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final CartRepository cartRepository;
    private final RoleRepository roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final CartItemRepository cartItemRepository;
    private final OrderStatusHistoryRepository orderStatusHistoryRepository;
    private final OrderItemRepository orderItemRepository;
    private final LoyaltyPointRepository loyaltyPointRepository;
    private final EmailService emailService;
    private final CouponRepository couponRepository;
    private final InventoryRepository inventoryRepository;


    @Override
    public ResponseEntity<?> createOrder(OrderRequest orderRequest, Principal principal) {
        // 1. Xác định giỏ hàng (user hoặc session)
        Optional<Cart> cart;
        User user;

        if (principal != null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            CustomUserDetails userDetails = (CustomUserDetails) auth.getPrincipal();
            user = userRepository.findById(userDetails.getId()).orElseThrow();
            cart = cartRepository.findByUserId(user.getId());
        }
        else {
            if (orderRequest.getSessionId() == null) {
                return ResponseEntity.badRequest().body("Session ID required");
            }

            cart = cartRepository.findBySessionId(orderRequest.getSessionId());
            if (cart.isEmpty()) {
                return ResponseEntity.badRequest().body("Cart not found");
            }

            // check khi user nhâp email để tạo tài khoản có exist không
            Optional<User> existingUser = userRepository.findByEmail(orderRequest.getEmail());
            if (existingUser.isPresent()) {
                return ResponseEntity.badRequest().body("Email already exists");
            }
            else {
                // Tạo tài khoản mới
                String passwordPlain = RandomStringUtils.randomAlphanumeric(8);
                user = new User();
                user.setEmail(orderRequest.getEmail());
                user.setFullName(orderRequest.getFullName());
                user.setPassword(passwordPlain);
                user.setShippingAddress(orderRequest.getShippingAddress());
                userRepository.save(user);

                // Role
                Role role = roleRepository.findByName("USER").orElseThrow();
                UserRole userRole = new UserRole();
                userRole.setRole(role);
                userRole.setUser(user);
                userRoleRepository.save(userRole);

                LoyaltyPoint loyaltyPointDefault = new LoyaltyPoint();
                loyaltyPointDefault.setUser(user);
                loyaltyPointDefault.setPoints(0);
                loyaltyPointDefault.setUpdatedAt(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));

                // Gửi email
                emailService.sendAccountCreated(user.getEmail(), passwordPlain);
            }


        }

        if (cart.isEmpty()) {
            return ResponseEntity.badRequest().body("Cart not found");
        }

        List<CartItem> cartItems = cartItemRepository.findByCartId(cart.get().getId());
        if (cartItems.isEmpty()) {
            return ResponseEntity.badRequest().body("Cart is empty");
        }

        // 2. Tinh tong tien
        double totalPrice = cartItems.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();

        // 3. Áp dụng mã coupon
        double discountCoupon = cart.get().getCoupon() != null ? cart.get().getCoupon().getDiscountPrice() : 0;
        int loyaltyPoint = cart.get().getLoyaltyPoint();

        double finalPrice = totalPrice - discountCoupon - loyaltyPoint;

        // 4. Tạo đơn hàng
        Order order = new Order();
        order.setUser(user);
        order.setPurchaseDate(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        order.setTotalAmount(finalPrice);
        order.setStatus("Pending");
        orderRepository.save(order);

        // 5. Tạo OrderStatusHistory
        OrderStatusHistory orderStatusHistory = new OrderStatusHistory();
        orderStatusHistory.setStatus("Pending");
        orderStatusHistory.setOrder(order);
        orderStatusHistory.setUpdateAt(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        orderStatusHistoryRepository.save(orderStatusHistory);

        // 6. Tạo order item
        for (CartItem item : cartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setVariant(item.getVariant());
            orderItem.setQuantity(item.getQuantity());
            orderItem.setPrice(item.getPrice());
            orderItemRepository.save(orderItem);
        }

        // 7. Cộng điểm loyalty mới
        int earnedPoints = (int) (totalPrice * 0.1);
        LoyaltyPoint loyaltyPoint1 = user.getLoyaltyPoint();
        if (loyaltyPoint1 == null) {
            loyaltyPoint1 = new LoyaltyPoint();
            loyaltyPoint1.setUser(user);
            loyaltyPoint1.setPoints(earnedPoints);
        }
        else {
            loyaltyPoint1.setPoints(loyaltyPoint1.getPoints() - loyaltyPoint + earnedPoints);
        }
        loyaltyPoint1.setUpdatedAt(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        loyaltyPointRepository.save(loyaltyPoint1);

        // 8. Cập nhật lại quantity Coupon
        String couponCode = cart.get().getCoupon().getCode();
        Optional<Coupon> coupon = couponRepository.findByCode(couponCode);
        if (coupon.isPresent()) {
            coupon.get().setQuantity(coupon.get().getQuantity() - 1);
            couponRepository.save(coupon.get());
        }

        // 9. Cập nhật lại số lượng Inventory của productVariant
        //  - Lấy danh sách của các VariantId
        List<Integer> variantIds = cartItems.stream()
                .map(cartItem -> cartItem.getVariant().getId())
                .toList();

        List<Inventory> inventories = inventoryRepository.findByProductVariantIds(variantIds);

        for (CartItem item: cartItems) {
            int variantId = item.getVariant().getId();
            inventories.stream()
                    .filter(inv -> inv.getProductVariant().getId() == variantId)
                    .findFirst()
                    .ifPresent(inv -> inv.setQuantity(inv.getQuantity() - item.getQuantity()));
        }

        inventoryRepository.saveAll(inventories);

        // 10. Xóa giỏ hàng
        cartItemRepository.deleteAll(cartItems);
        cartRepository.delete(cart.get());


        // 11. Gửi email xác nhận đơn hàng
        emailService.sendOrderConfirmation(user.getEmail(), order, cartItems);

        return ResponseEntity.ok().body("Order placed successfully");

    }

    @Override
    public ResponseEntity<?> trackOrder(int orderId, String newStatus) {
        Optional<Order> order = orderRepository.findById(orderId);
        if (order.isEmpty()) {
            return ResponseEntity.badRequest().body("Order not found");
        }

        // Cập nhật trang thái
        OrderStatusHistory orderStatusHistory = new OrderStatusHistory();
        orderStatusHistory.setOrder(order.get());
        orderStatusHistory.setStatus(newStatus);
        orderStatusHistory.setUpdateAt(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        orderStatusHistory = orderStatusHistoryRepository.save(orderStatusHistory);

        order.get().setStatus(orderStatusHistory.getStatus());
        orderRepository.save(order.get());

        return ResponseEntity.ok().body("Order's status updated successfully");
    }

    @Override
    public ResponseEntity<?> getOrderStatus(int orderId, Principal principal) {
        Optional<Order> order = orderRepository.findById(orderId);
        if (order.isEmpty()) {
            return ResponseEntity.badRequest().body("Order not found");
        }

        if (principal == null) {
            return ResponseEntity.badRequest().body("You are not logged in");
        }

        // Lấy list status theo orderId
        List<OrderStatusHistory> orderStatusHistoryList = orderStatusHistoryRepository.findByOrderIdOrderByUpdateAtDesc(orderId);

        List<Map<String, Object>> response = orderStatusHistoryList.stream()
                .map(h -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("status", h.getStatus());
                    map.put("updateAt", h.getUpdateAt());
                    return map;
                })
                .toList();

        return ResponseEntity.ok().body(response);
    }
}
