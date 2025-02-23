package com.zosh.service;

import java.util.List;

import com.zosh.exception.DriverException;
import com.zosh.exception.RideException;
import com.zosh.modal.DistanceTime;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.request.RideRequest;
import com.zosh.ride.domain.RideStatus;

public interface RideService {
	
	
	public Ride requestRide(RideRequest rideRequest, User user) throws Exception;
	
	public Ride createRideRequest(User user, Driver nearesDriver,
			double picupLatitude,double pickupLongitude,
			double destinationLatitude,double destinationLongitude,
			String pickupArea,String destinationArea,Long expectedDurationInMinutes);
	
	public void acceptRide(Integer rideId) throws RideException;
	
	public void declineRide(Integer rideId, Integer driverId) throws RideException;
	
	public void startRide(Integer rideId,int opt) throws RideException;
	
	public void completeRide(Integer rideId) throws RideException;
	
	public void cancleRide(Integer rideId) throws RideException;
	
	public Ride findRideById(Integer rideId) throws RideException;

	public DistanceTime getDistanceTimeBetweenDriverAndPickupArea(String driverArea, String pickupArea) throws Exception;

    public Ride createOrJoinCarpoolRide(String useremail, String pickupArea, String destinationArea);

	public List<Ride> findMatchingRides(String pickupArea, String destinationArea, RideStatus status);
    public void saveRide(Ride ride);
}
