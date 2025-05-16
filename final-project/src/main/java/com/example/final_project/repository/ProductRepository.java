package com.example.final_project.repository;

import com.example.final_project.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Integer>, JpaSpecificationExecutor<Product> {
//    @Query("SELECT p.category.name, SUM(oi.quantity) FROM Product p " +
//            "JOIN p.productVariantList v JOIN v.orderItems oi GROUP BY p.category.name")
//    List<Object[]> getProductCategoryStats();
}
