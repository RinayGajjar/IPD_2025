package com.zosh.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.zosh.modal.PaymentOrder;

public interface PaymentOrderRepo  extends JpaRepository<PaymentOrder,Long>{
}
