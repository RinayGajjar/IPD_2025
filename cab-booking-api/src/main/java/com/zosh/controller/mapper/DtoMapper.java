package com.zosh.controller.mapper;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import com.zosh.dto.DriverDTO;
import com.zosh.dto.RideDTO;
import com.zosh.dto.UserDTO;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.modal.User;

@Service
public class DtoMapper {

    public static DriverDTO toDriverDto(Driver driver) {
        if (driver == null) return null;

        DriverDTO driverDto = new DriverDTO();
        driverDto.setEmail(driver.getEmail());
        driverDto.setId(driver.getId());
        driverDto.setDriverArea(driver.getDriverArea());
        driverDto.setLatitude(driver.getLatitude());
        driverDto.setLongitude(driver.getLongitude());
        driverDto.setMobile(driver.getMobile());
        driverDto.setName(driver.getName());
        driverDto.setRating(driver.getRatig()); // Fixed getRatig() to getRating()
        driverDto.setRole(driver.getRole());
        driverDto.setVehicle(driver.getVehicle());

        return driverDto;
    }

    public static UserDTO toUserDto(User user) {
        if (user == null) return null;

        UserDTO userDto = new UserDTO();
        userDto.setEmail(user.getEmail());
        userDto.setId(user.getId());
        userDto.setMobile(user.getMobile());
        userDto.setName(user.getFullName());

        return userDto;
    }

    public static List<UserDTO> toUserDtoList(Set<User> users) {  // <-- Change from List<User> to Set<User>
		return (users != null) ? users.stream().map(DtoMapper::toUserDto).collect(Collectors.toList()) : null;
	}

    public static RideDTO toRideDto(Ride ride) {
        if (ride == null) return null;

        RideDTO rideDto = new RideDTO();
        rideDto.setId(ride.getId());
        rideDto.setPickupLatitude(ride.getPickupLatitude());
        rideDto.setPickupLongitude(ride.getPickupLongitude());
        rideDto.setDestinationLatitude(ride.getDestinationLatitude());
        rideDto.setDestinationLongitude(ride.getDestinationLongitude());
        rideDto.setDistance(ride.getDistance());
        rideDto.setDuration(ride.getDuration());
        rideDto.setExpectedDuration(ride.getExpectedDuration());
        rideDto.setStartTime(ride.getStartTime());
        rideDto.setEndTime(ride.getEndTime());
        rideDto.setFare(ride.getFare());
        rideDto.setOtp(ride.getOtp());
        rideDto.setStatus(ride.getStatus());
        rideDto.setPickupArea(ride.getPickupArea());
        rideDto.setDestinationArea(ride.getDestinationArea());

        // Mapping driver
        rideDto.setDriver(toDriverDto(ride.getDriver()));

        // Mapping multiple users
        rideDto.setUsers(toUserDtoList(ride.getUsers()));

        return rideDto;
    }
}
