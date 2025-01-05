package com.zosh.service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Random;

import org.hibernate.internal.build.AllowSysOut;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zosh.controller.mapper.DtoMapper;
import com.zosh.dto.DriverDTO;
import com.zosh.exception.DriverException;
import com.zosh.exception.RideException;
import com.zosh.modal.Driver;
import com.zosh.modal.Notification;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.repository.DriverRepository;
import com.zosh.repository.NotificationRepository;
import com.zosh.repository.RideRepository;
import com.zosh.request.RideRequest;
import com.zosh.ride.domain.NotificationType;
import com.zosh.ride.domain.RideStatus;

@Service
public class RideServiceImplementation implements RideService {
	
	@Autowired
	private DriverService driverService;
	
	@Autowired
	private RideRepository rideRepository;
	
	@Autowired
	private Calculaters calculaters;
	
	@Autowired
	private DriverRepository driverRepository;
	
	@Autowired
	private NotificationRepository notificationRepository;

	@Override
	public Ride requestRide(RideRequest rideRequest, User user) throws DriverException {
		
		double picupLatitude=rideRequest.getPickupLatitude();
		double picupLongitude=rideRequest.getPickupLongitude();
		double destinationLatitude=rideRequest.getDestinationLatitude();
		double destinationLongitude=rideRequest.getDestinationLongitude();
		String pickupArea=rideRequest.getPickupArea();
		String destinationArea=rideRequest.getDestinationArea();
		
		Ride existingRide = new Ride();
		
		List<Driver> availableDrivers=driverService.getAvailableDrivers(picupLatitude, 
				picupLongitude, 5, existingRide);
		
		Driver nearestDriver=driverService.findNearestDriver(availableDrivers, picupLatitude, picupLongitude);
		
		if(nearestDriver==null) {
			throw new DriverException("Driver not available");
		}
		
		System.out.println(" duration ----- before ride ");
		
        Ride ride = createRideRequest(user, nearestDriver, 
        		picupLatitude, picupLongitude, 
        		destinationLatitude, destinationLongitude,
        		pickupArea,destinationArea
        		);

        System.out.println(" duration ----- after ride ");
        
        // Send a notification to the driver
        Notification notification=new Notification();
        notification.setDriver(nearestDriver);
        notification.setMessage("You have been allocated to a ride");
        notification.setRid(ride);
        notification.setTimestamp(LocalDateTime.now());
        notification.setType(NotificationType.RIDE_REQUEST);
        
        Notification savedNofication = notificationRepository.save(notification);
        
//        rideService.sendNotificationToDriver(nearestDriver, ride);
        
        

        return ride;
        
		
	}

	@Override
	public Ride createRideRequest(User user, Driver nearesDriver, double pickupLatitude, 
			double pickupLongitude,double destinationLatitude, double destinationLongitude,
			String pickupArea,String destinationArea) {
		
		Ride ride=new Ride();

		ride.setDriver(nearesDriver);
		ride.setUser(user);
		ride.setPickupLatitude(pickupLatitude);
		ride.setPickupLongitude(pickupLongitude);
		ride.setDestinationLatitude(destinationLatitude);
		ride.setDestinationLongitude(destinationLongitude);
		ride.setStatus(RideStatus.REQUESTED);
		ride.setPickupArea(pickupArea);
		ride.setDestinationArea(destinationArea);
		
		System.out.println(" ----- a - " + pickupLatitude);
		
		return rideRepository.save(ride);
	}

	@Override
	public void acceptRide(Integer rideId) throws RideException {
		
		Ride ride=findRideById(rideId);
		
		ride.setStatus(RideStatus.ACCEPTED);
		
		Driver driver = ride.getDriver();
		
		driver.setCurrentRide(ride);
		
        Random random = new Random();
        
        int otp = random.nextInt(9000) + 1000;
        ride.setOtp(otp);
        
		driverRepository.save(driver);
		
		rideRepository.save(ride);
		
		Notification notification=new Notification();
		
        notification.setUser(ride.getUser());;
        notification.setMessage("Your Ride Is Conformed Driver Will Reach Soon At Your Pickup Location");
        notification.setRid(ride);
        notification.setTimestamp(LocalDateTime.now());
        notification.setType(NotificationType.RIDE_CONFIRMATION);
		
        Notification savedNofication = notificationRepository.save(notification);
		
	}

	@Override
	public void startRide(Integer rideId,int otp) throws RideException {
		Ride ride=findRideById(rideId);
		
		if(otp!=ride.getOtp()) {
			throw new RideException("please provide a valid otp");
		}
		
		ride.setStatus(RideStatus.STARTED);
		ride.setStartTime(LocalDateTime.now());
		rideRepository.save(ride);
	
		Notification notification=new Notification();
		
        notification.setUser(ride.getUser());;
        notification.setMessage("Driver Reached At Your Pickup Location");
        notification.setRid(ride);
        notification.setTimestamp(LocalDateTime.now());
        notification.setType(NotificationType.RIDE_CONFIRMATION);
		
        Notification savedNofication = notificationRepository.save(notification);
		
	}

	

	@Override
	public void completeRide(Integer rideId) throws RideException {
		Ride ride=findRideById(rideId);
		
		ride.setStatus(RideStatus.COMPLETED);
		ride.setEndTime(LocalDateTime.now());;
		
		double distence=calculaters.calculateDistance(ride.getDestinationLatitude(), ride.getDestinationLongitude(), ride.getPickupLatitude(), ride.getPickupLongitude());
		
		LocalDateTime start=ride.getStartTime();
		LocalDateTime end=ride.getEndTime();
		Duration duration = Duration.between(start, end);
		long milliSecond = duration.toMillis();


		System.out.println("duration ------- "+ milliSecond);
		double fare=calculaters.calculateFare(distence);
		
		ride.setDistence(Math.round(distence * 100.0) / 100.0);
		ride.setFare((int) Math.round(fare));
		ride.setDuration(milliSecond);
		ride.setEndTime(LocalDateTime.now());
		
		
		Driver driver =ride.getDriver();
		driver.getRides().add(ride);
		driver.setCurrentRide(null);
		
		Integer driversRevenue=(int) (driver.getTotalRevenue()+ Math.round(fare*0.8)) ;
		driver.setTotalRevenue(driversRevenue);
		
		System.out.println("drivers revenue -- "+driversRevenue);
		
		driverRepository.save(driver);
		rideRepository.save(ride);
		
		Notification notification=new Notification();
		
        notification.setUser(ride.getUser());;
        notification.setMessage("Driver Reached At Your Pickup Location");
        notification.setRid(ride);
        notification.setTimestamp(LocalDateTime.now());
        notification.setType(NotificationType.RIDE_CONFIRMATION);
		
        Notification savedNofication = notificationRepository.save(notification);
		
	}
	
	@Override
	public void cancleRide(Integer rideId) throws RideException {
		Ride ride=findRideById(rideId);
		ride.setStatus(RideStatus.CANCELLED);
		rideRepository.save(ride);
		
		
	}

	@Override
	public Ride findRideById(Integer rideId) throws RideException {
		Optional<Ride> ride=rideRepository.findById(rideId);
		
		if(ride.isPresent()) {
			return ride.get();
		}
		throw new RideException("ride not exist with id "+rideId);
	}

	@Override
	public void declineRide(Integer rideId, Integer driverId) throws RideException {
		
		Ride ride =findRideById(rideId);
		System.out.println(ride.getId());
		
		ride.getDeclinedDrivers().add(driverId);
		
		System.out.println(ride.getId()+" - "+ride.getDeclinedDrivers());
		
		List<Driver> availableDrivers=driverService.getAvailableDrivers(ride.getPickupLatitude(), 
				ride.getPickupLongitude(), 5,ride);
		
		Driver nearestDriver=driverService.findNearestDriver(availableDrivers, ride.getPickupLatitude(), 
				ride.getPickupLongitude());
		
		
		ride.setDriver(nearestDriver);
		
		rideRepository.save(ride);
		
	}

}
