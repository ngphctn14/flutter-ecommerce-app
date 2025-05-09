package com.example.final_project.controller;

import com.example.final_project.dto.ProductRequest;
import com.example.final_project.dto.ProductResponse;
import com.example.final_project.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;

    @PostMapping(value = "/api/v1/products", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> addProduct(
            @RequestPart("productRequest") ProductRequest productRequest,
            @RequestPart("file") MultipartFile file

    ) {
        return productService.addProduct(productRequest, file);
    }

    // Sắp xếp theo tên - gía (tăng dần, giảm dần)
    @GetMapping("/api/v1/products")
    public Page<ProductResponse> getAllProducts(
            @RequestParam int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "name") String sortBy,
            @RequestParam(defaultValue = "asc") String direction
    ) {
        return productService.getAllProducts(page, size, sortBy, direction);
    }

    // Search & Filter theo price, category, brand,...
    @GetMapping("/api/v1/products/filter")
    public Page<ProductResponse> getFilterProducts(
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) List<Integer> categoryIds,
            @RequestParam(required = false) List<Integer> brandIds,
            @RequestParam(required = false, defaultValue = "0") double minPrice,
            @RequestParam(required = false, defaultValue = "30000000") double maxPrice,
            @RequestParam int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "name") String sortBy,
            @RequestParam(defaultValue = "asc") String direction
    ) {
        return productService.getFilterProducts(keyword, categoryIds, brandIds, minPrice, maxPrice,
                page, size, sortBy, direction
        );
    }
}
