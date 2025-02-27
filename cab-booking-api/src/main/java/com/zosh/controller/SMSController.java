package com.zosh.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import com.zosh.modal.SMSMessage;

import lombok.Value;

@RestController
@RequestMapping("/api/sms")
public class SMSController {

	private String ACCOUNT_SID="";
	private String AUTH_TOKEN="";
	
	@PostMapping("/send")
	public ResponseEntity<SMSMessage>sendSMS(@RequestBody SMSMessage smsReq){
		
        Twilio.init(ACCOUNT_SID, AUTH_TOKEN);
        Message message = Message.creator(
                new com.twilio.type.PhoneNumber(smsReq.getMobile()),
                new com.twilio.type.PhoneNumber(""),
                smsReq.getMessage())
            .create();
        SMSMessage res=new SMSMessage();
        res.setMessage(message.getSid());
        res.setMobile(smsReq.getMobile());

        System.out.println(message.getSid());
        
        return  new ResponseEntity<SMSMessage>(res,HttpStatus.OK);
	}

}
