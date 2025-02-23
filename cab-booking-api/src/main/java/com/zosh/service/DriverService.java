package com.zosh.service;

import java.util.List;

import com.zosh.exception.DriverException;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.request.DriversSignupRequest;

public interface DriverService {
	
	public Driver registerDriver(DriversSignupRequest driverSignupRequest);
	public Driver createDriverFromRequest(DriversSignupRequest request);
	public List<Driver> getAvailableDrivers(String pickupArea,double radius, Ride ride);
	void updateDriverArea(String jwt,String newArea) throws DriverException;
	public Driver findNearestDriver(List<Driver> availableDrivers, 
			String pickupArea);
	
	public Driver getReqDriverProfile(String jwt) throws DriverException;
	
	public Ride getDriversCurrentRide(Integer driverId) throws DriverException;
	
	public Ride getAllocatedRides(Integer driverId) throws DriverException;
	
	public Driver findDriverById(Integer driverId) throws DriverException;
	
	public List<Ride> completedRids(Integer driverId) throws DriverException;
	
	
	



}
