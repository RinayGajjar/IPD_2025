package com.zosh.service;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.razorpay.Payment;
import com.razorpay.PaymentLink;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import com.zosh.modal.PaymentMethod;
import com.zosh.modal.PaymentOrder;
import com.zosh.modal.PaymentOrderStatus;
import com.zosh.modal.User;
import com.zosh.repository.PaymentOrderRepo;
import com.zosh.response.PaymentResponse;

@Service
public class PaymentServiceImpl implements PaymentService {

    @Autowired
    private PaymentOrderRepo paymentOrderRepo;

    // Set your API keys correctly
    @Value("${stripe.api.secret}")
    private String stripeSecurity;  // This is the secret key to be used

    @Value("${razorpay.api.key}")
    private String apikey;

    @Value("${razorpay.api.secret}")
    private String apiSecretKey;

    @Override
    public PaymentOrder createOrder(User user, Long amount, PaymentMethod paymentMethod) {
        PaymentOrder paymentOrder = new PaymentOrder();
        paymentOrder.setUser(user);
        paymentOrder.setAmount(amount);
        paymentOrder.setPaymentMethod(paymentMethod);
        paymentOrder.setStatus(PaymentOrderStatus.Pending);
        return paymentOrderRepo.save(paymentOrder);
    }

    @Override
    public PaymentOrder getPaymentOrderById(Long id) throws Exception {
        return paymentOrderRepo.findById(id).orElseThrow(() -> new Exception("Payment order not found"));
    }
    
    @Override
    public Boolean ProceedPaymentOrder(PaymentOrder paymentOrder, String paymentId) throws RazorpayException {
        if(paymentOrder.getStatus()==null){
            paymentOrder.setStatus(PaymentOrderStatus.Pending);
        }
        if (paymentOrder.getStatus().equals(PaymentOrderStatus.Pending)) {
            if (paymentOrder.getPaymentMethod().equals(PaymentMethod.Razorpay)) {
                RazorpayClient razorpay = new RazorpayClient(apikey, apiSecretKey);
                Payment payment = razorpay.payments.fetch(paymentId);
                String status = payment.get("status");
                if (status.equals("captured")) {
                    paymentOrder.setStatus(PaymentOrderStatus.Success);
                    paymentOrderRepo.save(paymentOrder);
                    return true;
                }
                paymentOrder.setStatus(PaymentOrderStatus.Failed);
                paymentOrderRepo.save(paymentOrder);
                return false;
            }
            paymentOrder.setStatus(PaymentOrderStatus.Success);
            paymentOrderRepo.save(paymentOrder);
            return true;
        }
        return false;
    }


    @Override
    public PaymentResponse createRazorPayPaymentLink(User user, Long amount, Long orderId) throws RazorpayException {
        Long Amount = amount * 100;
        try {
            RazorpayClient razorpay = new RazorpayClient(apikey, apiSecretKey);
            JSONObject paymentlinkRequest = new JSONObject();
            paymentlinkRequest.put("amount", Amount);
            paymentlinkRequest.put("currency", "INR");
            JSONObject customer = new JSONObject();
            customer.put("name", user.getFullName());
            customer.put("email", user.getEmail());
            paymentlinkRequest.put("customer", customer);

            JSONObject notify = new JSONObject();
            notify.put("email", true);
            paymentlinkRequest.put("notify", notify);
            paymentlinkRequest.put("reminder_enable", true);
            paymentlinkRequest.put("callback_url", "http://localhost:3000/wallet?order_id=" + orderId);
            paymentlinkRequest.put("callback_method", "get");

            PaymentLink payment = razorpay.paymentLink.create(paymentlinkRequest);

            String paymentLinkUrl = payment.get("short_url");

            PaymentResponse res = new PaymentResponse();
            res.setPayment_url(paymentLinkUrl);
            return res;
        } catch (RazorpayException e) {
            System.out.println("Error creating payment link: " + e.getMessage());
            throw new RazorpayException(e.getMessage());
        }
    }

    @Override
    public PaymentResponse createStripePayPaymentLink(User user, Long amount, Long orderId) throws StripeException {
        Stripe.apiKey = stripeSecurity;  // Use the secret key here
    
        SessionCreateParams params = SessionCreateParams.builder()
            .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
            .setMode(SessionCreateParams.Mode.PAYMENT)
            .setSuccessUrl("http://localhost:3000/wallet?order_id=" + orderId + "&session_id={CHECKOUT_SESSION_ID}")
            .addLineItem(SessionCreateParams.LineItem.builder()
                .setQuantity(1L)
                .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency("usd")
                    .setUnitAmount(amount * 100)
                    .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                        .setName("Top up a wallet")
                        .build())
                    .build())
                .build())
            .build();
    
        Session session = Session.create(params);
    
        PaymentResponse res = new PaymentResponse();
        res.setPayment_url(session.getUrl());
        return res;
    }
    @Override
  public String getPaymentIdFromSession(String sessionId) throws StripeException  {
    // Retrieve the session using the session ID
    Session session = Session.retrieve(sessionId);
    // Get the payment intent ID from the session
    return session.getPaymentIntent();
}

    
}
