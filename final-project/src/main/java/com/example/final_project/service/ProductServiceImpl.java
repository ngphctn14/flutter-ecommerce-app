package com.example.final_project.service;

import com.example.final_project.cloudinary.CloudinaryService;
import com.example.final_project.dto.ProductRequest;
import com.example.final_project.dto.ProductResponse;
import com.example.final_project.entity.Brand;
import com.example.final_project.entity.Category;
import com.example.final_project.entity.Product;
import com.example.final_project.repository.BrandRepository;
import com.example.final_project.repository.CategoryRepository;
import com.example.final_project.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    public ResponseEntity<String> addProduct(ProductRequest productRequest, MultipartFile file) {
        if (productRequest == null) {
            return ResponseEntity.badRequest().body("Please provide a valid product");
        }

        // Check category
        Optional<Category> category = categoryRepository.findById(productRequest.getCategory_id());
        if (category.isEmpty()) {
            return ResponseEntity.badRequest().body("Category not found");
        }

        // Check brand
        Optional<Brand> brand = brandRepository.findById(productRequest.getBrand_id());
        if (brand.isEmpty()) {
            return ResponseEntity.badRequest().body("Brand not found");
        }

        // check file image
        String url_image = "";
        try {
            url_image = cloudinaryService.uploadImage(file);
        } catch (IOException e) {
            return ResponseEntity.badRequest().body("Image cannot be uploaded");
        }

        Product product = Product.builder()
                .name(productRequest.getName())
                .price(productRequest.getPrice())
                .specs(productRequest.getSpecs())
                .description(productRequest.getDescription())
                .image(url_image)
                .brand(brand.get())
                .category(category.get())
                .build();

        productRepository.save(product);
        return ResponseEntity.ok().body("Product added successfully!");
    }

    @Override
    public Page<ProductResponse> getAllProducts(int page, int size, String sortBy, String direction) {
        Sort sort = direction.equalsIgnoreCase("desc") ?
                Sort.by(sortBy).descending() : Sort.by(sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Product> products = productRepository.findAll(pageable);


        return products.map(this::mapToResponse);
    }

    @Override
    public Page<ProductResponse> getFilterProducts(String keyword, List<Integer> categoryIds, List<Integer> brandIds, double minPrice, double maxPrice, int page, int size, String sortBy, String direction) {
        Sort sort = direction.equalsIgnoreCase("desc") ?
                Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);

        Specification<Product> spec = Specification.where(null);

        if (!keyword.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                    cb.like(cb.lower(root.get("name")), "%" + keyword.toLowerCase() + "%"));
        }

        if (brandIds != null && !brandIds.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                    root.get("brand").get("id").in(brandIds));
        }

        if (categoryIds != null && !categoryIds.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                    root.get("category").get("id").in(categoryIds));
        }

        spec = spec.and((root, query, cb) ->
                cb.between(root.get("price"), minPrice, maxPrice));

        Page<Product> productPage = productRepository.findAll(spec, pageable);
        return productPage.map(this::mapToResponse);
    }

    private ProductResponse mapToResponse(Product product) {
        return ProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .price(product.getPrice())
                .image(product.getImage())
                .description(product.getDescription())
                .specs(product.getSpecs())
                .categoryName(product.getCategory().getName())
                .brandName(product.getBrand().getName())
                .build();
    }


}
