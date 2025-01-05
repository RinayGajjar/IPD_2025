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
		DriverDTO driverDTO=toDriverDto(ride.getDriver());
		UserDTO userDto=toUserDto(ride.getUser());
		
		RideDTO rideDto=new RideDTO();
		
		rideDto.setDestinationLatitude(ride.getDestinationLatitude());
		rideDto.setDestinationLongitude(ride.getDestinationLongitude());
		rideDto.setDistance(ride.getDistence());
		rideDto.setDriver(driverDTO);
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
		rideDto.setPaymentDetails(ride.getPaymentDetails());
		rideDto.setOtp(ride.getOtp());
		return rideDto;
	}
	

	

}
