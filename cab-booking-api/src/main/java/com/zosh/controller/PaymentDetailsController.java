package com.zosh.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.zosh.modal.PaymentDetails;
import com.zosh.modal.User;
import com.zosh.service.PaymentDetailsService;
import com.zosh.service.UserService;

@RestController
@CrossOrigin("*")
@RequestMapping("/api")
public class PaymentDetailsController {
     @Autowired
    private UserService userService;

    @Autowired
    private PaymentDetailsService paymentDetailsService;

     @PostMapping("/payment-details")
    public ResponseEntity<PaymentDetails> addPaymentDetails(@RequestBody PaymentDetails paymentDetailsReq,@RequestHeader("Authorization") String jwt) throws Exception{
        User user=userService.findUserByToken(jwt);
        PaymentDetails paymentDetails=paymentDetailsService.addpaymentdetails(paymentDetailsReq.getAccountno(), paymentDetailsReq.getAccountholdername(),paymentDetailsReq.getIfsc(), paymentDetailsReq.getBankname(), user);
        return new ResponseEntity<>(paymentDetails,HttpStatus.CREATED);
    }
    @GetMapping("/payment-details")
public ResponseEntity<?> getUserPaymentDetails(@RequestHeader("Authorization") String jwt) throws Exception {
    User user = userService.findUserByToken(jwt);
    PaymentDetails paymentDetails = paymentDetailsService.getUserpaymentDetails(user);

    if (paymentDetails == null) {
        return new ResponseEntity<>("Payment details not found for user", HttpStatus.NOT_FOUND);
    }

    return new ResponseEntity<>(paymentDetails, HttpStatus.OK);
}

}
