package com.zosh.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.zosh.config.JwtUtil;
import com.zosh.exception.UserException;
import com.zosh.modal.Driver;
import com.zosh.modal.User;
import com.zosh.repository.DriverRepository;
import com.zosh.repository.UserRepository;
import com.zosh.response.MessageResponse;

@RestController
public class HomeController {
	
	@Autowired
	private JwtUtil jwtUtil;
	
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private DriverRepository driverRepository;
	
	@GetMapping({"/api","/"})
	public ResponseEntity<MessageResponse> homeController(){
		MessageResponse res=new MessageResponse("welcome to cab booking api");
		
		return new ResponseEntity<MessageResponse>(res,HttpStatus.ACCEPTED);
		
	}
	
	@GetMapping("/api/profile")
	public ResponseEntity<?> userProfileHandler(@RequestHeader("Authorization") String jwt) throws UserException{
		
		
		
		String email=jwtUtil.getEmailFromToken(jwt);
		
		if(email==null) {
			throw new BadCredentialsException("invalid token recived");
		}
		
		Driver driver=driverRepository.findByEmail(email);
		
		if(driver!=null) {
			return new ResponseEntity<Driver>(driver,HttpStatus.ACCEPTED);
		}
		
		User user=userRepository.findByEmail(email);
		
		if(user!=null) {
			System.out.println("user - "+user.getEmail());
			return new ResponseEntity<User>(user,HttpStatus.ACCEPTED);
		}
		
		throw new UserException("user not found with email "+email);
	}

}
