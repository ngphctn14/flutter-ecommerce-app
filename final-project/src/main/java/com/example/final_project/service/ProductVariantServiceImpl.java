package com.example.final_project.service;

import com.example.final_project.cloudinary.CloudinaryService;
import com.example.final_project.dto.InventoryRequest;
import com.example.final_project.dto.ProductVariantRequest;
import com.example.final_project.dto.ProductVariantResponse;
import com.example.final_project.entity.Images;
import com.example.final_project.entity.Inventory;
import com.example.final_project.entity.Product;
import com.example.final_project.entity.ProductVariant;
import com.example.final_project.repository.ImagesRepository;
import com.example.final_project.repository.InventoryRepository;
import com.example.final_project.repository.ProductRepository;
import com.example.final_project.repository.ProductVariantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductVariantServiceImpl implements ProductVariantService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository productVariantRepository;
    private final InventoryRepository inventoryRepository;
    private final CloudinaryService cloudinaryService;
    private final ImagesRepository imagesRepository;

    @Override
    public ResponseEntity<String> createProductVariant(ProductVariantRequest productVariantRequest, List<MultipartFile> files) {
        Optional<Product> product = productRepository.findById(productVariantRequest.getProductId());
        if (product.isPresent()) {
            ProductVariant productVariant = ProductVariant.builder()
                    .specs(productVariantRequest.getSpecs())
                    .variantName(productVariantRequest.getVariantName())
                    .priceDiff(productVariantRequest.getPriceDiff())
                    .product(product.get())
                    .build();

            // Lưu images
            List<Images> images = new ArrayList<>();
            for (MultipartFile file : files) {
                Images image = new Images();
                String urlImage = "";
                try {
                    urlImage = cloudinaryService.uploadImage(file);
                    image.setImagePath(urlImage);
                    image.setProductVariant(productVariant);
                } catch (IOException e) {
                    return ResponseEntity.badRequest().body("Image can not be uploaded");
                }
                images.add(image);
            }

            // Save variant before inventory
            productVariant = productVariantRepository.save(productVariant);

            Inventory inventory = Inventory.builder()
                    .productVariant(productVariant)
                    .quantity(productVariantRequest.getQuantity())
                    .build();

            inventoryRepository.save(inventory);

            // Save images
            imagesRepository.saveAll(images);

            return ResponseEntity.ok().body("Product variant created");
        }
        return ResponseEntity.badRequest().body("Product not found");
    }

    @Override
    public ResponseEntity<String> updateQuantityProductVariant(InventoryRequest inventoryRequest) {
        Optional<ProductVariant> productVariant = productVariantRepository.findById(inventoryRequest.getProductId());
        Optional<Inventory> inventory = inventoryRepository.findByProductVariantId(productVariant.get().getId());
        if (inventory.isPresent()) {
            inventory.get().setQuantity(inventoryRequest.getQuantity());
            inventoryRepository.save(inventory.get());
            return ResponseEntity.ok().body("Product variant updated");
        }
        return ResponseEntity.badRequest().body("ProductVariant not found");
    }

    @Override
    public ResponseEntity<?> getProductVariants(int productId) {
        List<ProductVariant> productVariantList = productVariantRepository.findByProductId(productId);
        if (productVariantList.isEmpty()) {
            return ResponseEntity.badRequest().body("Product not found");
        }

        List<ProductVariantResponse> productVariantResponses = productVariantList.stream()
                .map(productVariant -> ProductVariantResponse.builder()
                        .id(productVariant.getId())
                        .variantName(productVariant.getVariantName())
                        .priceDiff(productVariant.getPriceDiff())
                        .specs(productVariant.getSpecs())
                        .quantity(productVariant.getInventory().getQuantity())
                        .images(productVariant.getImages().stream()
                                .map(Images::getImagePath)
                                .toList())
                        .build())
                .toList();
        return ResponseEntity.ok().body(productVariantResponses);
    }

    @Override
    public ResponseEntity<String> deleteProductVariant(int productVariant_id) {
        Optional<ProductVariant> productVariant = productVariantRepository.findById(productVariant_id);
        if (productVariant.isPresent()) {
            productVariantRepository.delete(productVariant.get());

            // Sau khi xóa variant -> xóa inventory của variant đó
            Optional<Inventory> inventory = inventoryRepository.findByProductVariantId(productVariant.get().getId());
            inventory.ifPresent(inventoryRepository::delete);
            return ResponseEntity.ok().body("Product variant deleted");
        }
        return ResponseEntity.badRequest().body("Product variant not found");
    }
}
