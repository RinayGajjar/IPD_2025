package com.zosh.service;

import org.springframework.stereotype.Service;

import com.razorpay.RazorpayException;
import com.stripe.exception.StripeException;
import com.zosh.modal.PaymentMethod;
import com.zosh.modal.PaymentOrder;
import com.zosh.modal.User;
import com.zosh.response.PaymentResponse;

@Service
public interface PaymentService {
    PaymentOrder createOrder(User user,Long amount,PaymentMethod paymentMethod);
    PaymentOrder getPaymentOrderById(Long id) throws Exception;
    Boolean ProceedPaymentOrder(PaymentOrder paymentOrder,String paymentId) throws RazorpayException, StripeException;
    PaymentResponse createRazorPayPaymentLink(User user,Long amount,Long orderId) throws RazorpayException;
    PaymentResponse createStripePayPaymentLink(User user,Long amount,Long orderId) throws StripeException;
    String   getPaymentIdFromSession(String sessionId) throws StripeException, Exception;
}
