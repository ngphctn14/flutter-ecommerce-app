package com.example.final_project.service;

import com.example.final_project.entity.CartItem;
import com.example.final_project.entity.Order;
import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class EmailService {
    private final JavaMailSender javaMailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public void send(String toEmail, String subject, String body) {
            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setFrom(fromEmail);
                message.setTo(toEmail);
                message.setSubject(subject);
                message.setText(body);
                javaMailSender.send(message);
            } catch (Exception e) {
                e.printStackTrace(); // hoặc log lỗi
            }
    }

    /**
     * Gửi email khi tạo tài khoản cho khách mới chưa đăng nhập
     */
    public void sendAccountCreated(String toEmail, String plainPassword) {
        String subject = "Tài khoản của bạn đã được tạo tại SpringCommerce!";
        String body = "Xin chào,\n\n"
                + "Bạn vừa được tạo tài khoản tự động khi đặt hàng tại SpringCommerce.\n"
                + "Email đăng nhập: " + toEmail + "\n"
                + "Mật khẩu tạm thời: " + plainPassword + "\n\n"
                + "Bạn có thể đăng nhập và đổi mật khẩu bất kỳ lúc nào.\n"
                + "Trân trọng,\nSpringCommerce Team";
        send(toEmail, subject, body);
    }

    /**
     * Gửi email khi khôi phục password
     */
    public void sendOTPEmailRecoveryPassword(String toEmail, String otp) {
        String subject = "Mã OTP khôi phục mật khẩu";
        String content = "Chào " + toEmail + ",\n\n"
                + "Mã OTP để khôi phục mật khẩu của bạn là: " + otp + "\n\n"
                + "Mã OTP có hiệu lực trong 5 phút.\n"
                + "Nếu bạn không yêu cầu, vui lòng bỏ qua email này.\n\n"
                + "Cảm ơn bạn.";

        send(toEmail, subject, content);
    }

    /**
     * Gửi email xác nhận đơn hàng
     */
    public void sendOrderConfirmation(String toEmail, Order order, List<CartItem> items) {
        // Định dạng tiền tệ
        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        // Định dạng ngày giờ
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        // Tạo nội dung email HTML
        StringBuilder content = new StringBuilder();
        content.append("<!DOCTYPE html>");
        content.append("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
        content.append("<h2 style='color: #2e7d32;'>🛒 Đơn hàng của bạn đã được xác nhận!</h2>");
        content.append("<p><strong>Mã đơn hàng:</strong> ").append(order.getId()).append("</p>");
        content.append("<p><strong>Ngày đặt:</strong> ")
                .append(order.getPurchaseDate().format(dateFormatter)).append("</p>");
        content.append("<h3 style='color: #1976d2;'>📦 Danh sách sản phẩm:</h3>");
        content.append("<ul>");
        for (CartItem item : items) {
            content.append("<li>")
                    .append(item.getVariant().getVariantName())
                    .append(" x").append(item.getQuantity())
                    .append(" - ").append(currencyFormat.format(item.getPrice()))
                    .append("</li>");
        }
        content.append("</ul>");
        content.append("<p><strong>🧾 Tổng cộng:</strong> ")
                .append(currencyFormat.format(order.getTotalAmount())).append("</p>");
        content.append("<p><strong>Địa chỉ giao hàng:</strong> ")
                .append(order.getUser().getShippingAddress()).append("</p>");
        content.append("<p style='margin-top: 20px;'>Cảm ơn bạn đã mua sắm tại <strong>SpringCommerce</strong>!</p>");
        content.append("<p style='font-size: 0.9em; color: #777;'>Trân trọng,<br>SpringCommerce Team</p>");
        content.append("</body></html>");

        // Gửi email
        send(toEmail, "Xác nhận đơn hàng #" + order.getId(), content.toString());
    }
}
