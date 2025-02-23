package com.zosh.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.zosh.exception.DriverException;
import com.zosh.exception.UserException;
import com.zosh.modal.Ride;
import com.zosh.modal.User;

@Service
public interface UserService {
	
	public User createUser(User user) throws UserException;
	
	public User getReqUserProfile(String token) throws UserException;
	
	public User findUserById(Long Id) throws UserException;
	
	public User findUserByEmail(String email) throws UserException;
	
	public User findUserByToken(String token) throws UserException;
	
	// public List<Ride> completedRids(Long userId) throws UserException;
	// public Ride getAllocatedRides(Integer userId) throws UserException;
	

}
