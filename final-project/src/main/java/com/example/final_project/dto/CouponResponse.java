package com.example.final_project.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class CouponResponse {
    private int id;

    private String code;
    private double discountPrice;
    private int quantity;
    private boolean active;
}
