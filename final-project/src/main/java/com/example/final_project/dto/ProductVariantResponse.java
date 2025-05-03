package com.example.final_project.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter @Setter
@Builder
public class ProductVariantResponse {
    private int id;

    private String variantName;
    private double priceDiff;   // Gia chenh lech
    private String specs;       // Lưu thông số product (RAM, ROM,...)

    // Lưu inventory
    private int quantity;

    // Lưu images
    private List<String> images;
}
