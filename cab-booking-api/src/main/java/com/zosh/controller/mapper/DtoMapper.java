package com.zosh.controller.mapper;

import org.springframework.stereotype.Service;

import com.zosh.dto.DriverDTO;
import com.zosh.dto.RideDTO;
import com.zosh.dto.UserDTO;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.modal.User;

@Service
public class DtoMapper {
	
	public static DriverDTO toDriverDto(Driver driver){
		
		DriverDTO driverDto=new DriverDTO();
		
		driverDto.setEmail(driver.getEmail());
		driverDto.setId(driver.getId());
		driverDto.setDriverArea(driver.getDriverArea());
		driverDto.setLatitude(driver.getLatitude());
		driverDto.setLongitude(driver.getLongitude());
		driverDto.setMobile(driver.getMobile());
		driverDto.setName(driver.getName());
		driverDto.setRating(driver.getRatig());
		driverDto.setRole(driver.getRole());
		driverDto.setVehicle(driver.getVehicle());
		
		
		return driverDto;
		
	}
	public static UserDTO toUserDto(User user) {
		
		UserDTO userDto=new UserDTO();
		
		userDto.setEmail(user.getEmail());
		userDto.setId(user.getId());
		userDto.setMobile(user.getMobile());
		userDto.setName(user.getFullName());
		
		return userDto;
		
	}
	
	public static RideDTO toRideDto(Ride ride) {
		// Check for null driver and user before mapping
		DriverDTO driverDTO = (ride.getDriver() != null) ? toDriverDto(ride.getDriver()) : null;
		UserDTO userDto = (ride.getUser() != null) ? toUserDto(ride.getUser()) : null;
		
		RideDTO rideDto = new RideDTO();
		
		// Map fields, ensuring null-safe operations
		rideDto.setDestinationLatitude(ride.getDestinationLatitude());
		rideDto.setDestinationLongitude(ride.getDestinationLongitude());
		rideDto.setDistance(ride.getDistance());
		rideDto.setDriver(driverDTO);
		rideDto.setExpectedDuration(ride.getExpectedDuration());
		rideDto.setDuration(ride.getDuration());
		rideDto.setEndTime(ride.getEndTime());
		rideDto.setFare(ride.getFare());
		rideDto.setId(ride.getId());
		rideDto.setPickupLatitude(ride.getPickupLatitude());
		rideDto.setPickupLongitude(ride.getPickupLongitude());
		rideDto.setStartTime(ride.getStartTime());
		rideDto.setStatus(ride.getStatus());
		rideDto.setUser(userDto);
		rideDto.setPickupArea(ride.getPickupArea());
		rideDto.setDestinationArea(ride.getDestinationArea());
		
		// Check if payment details exist
		// if (ride.getPaymentDetails() != null) {
		// 	rideDto.setPaymentDetails(ride.getPaymentDetails());
		// }
		
		// Set OTP, handling potential null values
		rideDto.setOtp(ride.getOtp());
		
		return rideDto;
	}


}
