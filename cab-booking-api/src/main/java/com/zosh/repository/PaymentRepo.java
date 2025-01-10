package com.zosh.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.zosh.modal.PaymentDetails;

public interface PaymentRepo  extends JpaRepository<PaymentDetails,Long>{
    PaymentDetails findByUserId(Long userId);
}
