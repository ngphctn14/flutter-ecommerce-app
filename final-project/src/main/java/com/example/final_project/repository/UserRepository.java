package com.example.final_project.repository;

import com.example.final_project.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByFullName(String fullName);
    Optional<User> findByEmail(String email);
}
