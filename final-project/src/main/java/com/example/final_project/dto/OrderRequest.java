package com.example.final_project.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
@Builder
public class OrderRequest {
    private String fullName;
    private String email;

    // id của address mà user chọn
    private int addressId;
    private String shippingAddress;
    private String sessionId;
}
