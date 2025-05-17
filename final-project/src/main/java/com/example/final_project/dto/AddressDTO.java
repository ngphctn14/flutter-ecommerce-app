package com.example.final_project.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class AddressDTO {
    private String province;
    private String provinceCode;

    private String district;
    private String districtCode;

    private String ward;
    private String wardCode;

    private String addressDetail;
}
