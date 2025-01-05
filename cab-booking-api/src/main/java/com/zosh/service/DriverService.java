package com.zosh.service;

import java.util.List;

import com.zosh.exception.DriverException;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.request.DriversSignupRequest;

public interface DriverService {
	
	public Driver registerDriver(DriversSignupRequest driverSignupRequest);
	
	public List<Driver> getAvailableDrivers(double pickupLatitude,
			double picupLongitude,double radius, Ride ride);
	
	public Driver findNearestDriver(List<Driver> availableDrivers, 
			double picupLatitude, double picupLongitude);
	
	public Driver getReqDriverProfile(String jwt) throws DriverException;
	
	public Ride getDriversCurrentRide(Integer driverId) throws DriverException;
	
	public List<Ride> getAllocatedRides(Integer driverId) throws DriverException;
	
	public Driver findDriverById(Integer driverId) throws DriverException;
	
	public List<Ride> completedRids(Integer driverId) throws DriverException;
	
	
	



}
