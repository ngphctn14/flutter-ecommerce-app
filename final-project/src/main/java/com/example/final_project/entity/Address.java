package com.example.final_project.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int address_id;

    // Tên và mã tỉnh
    private String province;
    private String provinceCode;

    // Tên và mã huyện
    private String district;
    private String districtCode;

    // Tên và mã xã
    private String ward;
    private String wardCode;

    // Địa chỉ chi tiết (số nhà, ấp, thôn...)
    private String addressDetail;

    private boolean isDefault;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
