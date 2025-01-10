package com.zosh.service;

import org.springframework.stereotype.Service;

import com.zosh.modal.PaymentDetails;
import com.zosh.modal.User;

@Service
public interface PaymentDetailsService {
    public PaymentDetails addpaymentdetails(String accountnumber,String accountholdername,String ifsc,String bankname,User user);
    public PaymentDetails getUserpaymentDetails(User user);
}
