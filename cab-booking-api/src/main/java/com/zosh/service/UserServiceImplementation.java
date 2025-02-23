package com.zosh.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import com.zosh.config.JwtUtil;
import com.zosh.exception.DriverException;
import com.zosh.exception.UserException;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.repository.UserRepository;


@Service
public class UserServiceImplementation implements UserService {
	
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private JwtUtil jwtUtil;

	@Override
	public User createUser(User user) throws UserException {
		
		User emailExist = findUserByEmail(user.getEmail());
		
		if(emailExist!=null)throw new UserException("Email Already Used With Another Account");
		

		
		return userRepository.save(user);
		
	}

	@Override
	public User findUserById(Long userId) throws UserException {
		
		Optional<User> opt=userRepository.findById(userId);
		
		if(opt.isPresent()) {
			return opt.get();
		}
		throw new UserException("user not found with id "+userId);
	}

	@Override
	public User findUserByEmail(String email) throws UserException {
		
		User user=userRepository.findByEmail(email);
		
		if(user!=null) {
			return user;
		}
		throw new UserException("user not found with email "+email);
	}

	@Override
	public User getReqUserProfile(String token) throws UserException {
		
		String email = jwtUtil.getEmailFromToken(token);
		User user = userRepository.findByEmail(email);
		 
		if(user!=null) {
			return user;
		}
		
		throw new UserException("invalid token...");
		
	}

	@Override
	public User findUserByToken(String token) throws UserException {
		String email=jwtUtil.getEmailFromToken(token);
		if(email==null) {
			throw new BadCredentialsException("invalid token recived");
		}
		User user=userRepository.findByEmail(email);
		
		if(user!=null) {
			return user;
		}
		throw new UserException("user not found with email "+email);
	}

	// @Override
	// public List<Ride> completedRids(Long userId) throws UserException {
	// 	List <Ride> completedRides=userRepository.getCompletedRides(userId);
	// 	return completedRides;
	// }
	// @Override
	// public Ride getAllocatedRides(Integer userId) throws UserException {
	// 	List<Ride> rides=userRepository.getAllocatedRides(userId);
	// 	if(rides==null || rides.isEmpty()) {
	// 		throw new UserException("No allocated rides found for userId: "+userId);
	// 	}
	// 	return rides.get(0);
	// }

	// List<Ride> rides = driverRepository.getAllocatedRides(driverId);

    // if (rides == null || rides.isEmpty()) {
    //     throw new DriverException("No allocated rides found for driverId: " + driverId);
    // }

    // // Return the first ride (most recent based on query order or additional logic)
    // return rides.get(0);

}
