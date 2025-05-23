package com.zosh.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.zosh.exception.DriverException;
import com.zosh.exception.UserException;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.service.UserService;

@RestController
@RequestMapping("/api/users")
public class UserController {
	@Autowired
	private UserService userService;
	
	@GetMapping("/{userId}")
	public ResponseEntity<User> findUserByIdHandler(@PathVariable Long userId)throws UserException{
		System.out.println("find by user id");
		User createdUser = userService.findUserById(userId);
		
		return new ResponseEntity<User>(createdUser,HttpStatus.ACCEPTED);
		
	}
	
	@GetMapping("/profile")
	public ResponseEntity<User> getReqUserProfileHandler(@RequestHeader("Authorization") String jwt) throws UserException{
		
		User user=userService.getReqUserProfile(jwt);
		
		return new ResponseEntity<User>(user,HttpStatus.ACCEPTED);
	}
	
	// @GetMapping("/rides/completed")
	// public ResponseEntity<List<Ride>> getcompletedRidesHandler(@RequestHeader("Authorization") String jwt) throws UserException {
		
	// 	User user = userService.getReqUserProfile(jwt);
		
	// 	List<Ride> rides=userService.completedRids(user.getId());
		
	// 	return new ResponseEntity<>(rides,HttpStatus.ACCEPTED);
	// }

	// @GetMapping("/rides/allocated/{userId}")
	// public ResponseEntity<Ride> getAllocatedRidesHandler(@PathVariable Integer userId) throws UserException{
	// 	Ride ride=userService.getAllocatedRides(userId);
		
	// 	return new ResponseEntity<>(ride,HttpStatus.ACCEPTED);
	// }

	

}
