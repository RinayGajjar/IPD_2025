package com.zosh.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.zosh.config.JwtUtil;
import com.zosh.controller.mapper.DtoMapper;
import com.zosh.dto.DriverDTO;
import com.zosh.exception.DriverException;
import com.zosh.exception.RideException;
import com.zosh.modal.Coordinates;
import com.zosh.modal.DistanceTime;
import com.zosh.modal.Driver;
import com.zosh.modal.Notification;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.repository.DriverRepository;
import com.zosh.repository.NotificationRepository;
import com.zosh.repository.RideRepository;
import com.zosh.repository.UserRepository;
import com.zosh.request.RideRequest;
import com.zosh.ride.domain.NotificationType;
import com.zosh.ride.domain.RideStatus;

@Service
public class RideServiceImplementation implements RideService {

	@Autowired
	private JwtUtil jwtUtil;
	
	@Autowired
	private DriverService driverService;
	
	@Autowired
	private RideRepository rideRepository;

	@Autowired 
	private UserRepository userRepository;
	
	@Autowired
	private Calculaters calculaters;
	
	@Autowired
	private DriverRepository driverRepository;
	
	@Autowired
	private NotificationRepository notificationRepository;

	@Autowired
	private MapService mapService;

	private static final Logger logger=LoggerFactory.getLogger(RideServiceImplementation.class);

	@Override
	public Ride requestRide(RideRequest rideRequest, User user) throws Exception   {
		

		// double picupLatitude=rideRequest.getPickupLatitude();
		// double picupLongitude=rideRequest.getPickupLongitude();
		// double destinationLatitude=rideRequest.getDestinationLatitude();
		// double destinationLongitude=rideRequest.getDestinationLongitude();

		double picupLatitude=0.0;
		double picupLongitude=0.0;
		double destinationLatitude=0.0;
		double destinationLongitude=0.0;

		try {
			Coordinates pickupCoordinates=mapService.getAddressCoordinates(rideRequest.getPickupArea());
			if (pickupCoordinates == null) throw new Exception("Invalid pickup location");
			picupLatitude=pickupCoordinates.getLat();
			picupLongitude=pickupCoordinates.getLng();
			logger.debug("Pickup coordinates: lat = {}, lng = {}", picupLatitude, picupLongitude);
		} catch (Exception e) {
			logger.error("Unable to fetch coordinates for pickup area: {}", e.getMessage());
			throw new Exception("Unable to fetch coordinates for pickup area------------------------------: " + e.getMessage());
		}

		try {
			Coordinates destinationCoordinates = mapService.getAddressCoordinates(rideRequest.getDestinationArea());
			if (destinationCoordinates == null) throw new Exception("Invalid destination location");
			destinationLatitude=destinationCoordinates.getLat();
			destinationLongitude=destinationCoordinates.getLng();
			logger.debug("Destination coordinates: lat = {}, lng = {}", destinationLatitude, destinationLongitude);
		} catch (Exception e) {
			logger.error("Unable to fetch coordinates for destination area: {}", e.getMessage());
			throw new Exception("Unable to fetch coordinates for destination area: " + e.getMessage());
		}

		Ride existingRide = new Ride();
		
		//send here pickup area 
		logger.info("Ride request - Pickup area: {}, Destination area: {}", rideRequest.getPickupArea(), rideRequest.getDestinationArea());
		List<Driver> availableDrivers=driverService.getAvailableDrivers(rideRequest.getPickupArea(),5, existingRide);
		//also here 
		Driver nearestDriver=driverService.findNearestDriver(availableDrivers,rideRequest.getPickupArea());
		
		if(nearestDriver==null) {
			logger.error("No driver available for the requested pickup area.");
			throw new Exception("Driver not available");
		}
		
		logger.debug("Nearest driver: {}", nearestDriver.getId());
		
        Ride ride = createRideRequest(user, nearestDriver, 
        		picupLatitude, picupLongitude, 
        		destinationLatitude, destinationLongitude,
        		rideRequest.getPickupArea(),rideRequest.getDestinationArea()
        		,rideRequest.getExpectedDuration());

				logger.debug("Ride created with ID: {}", ride.getId());
        
        // Send a notification to the driver
        Notification notification=new Notification();
        notification.setDriver(nearestDriver);
        notification.setMessage("You have been allocated to a ride");
        notification.setRide(ride);
        notification.setTimestamp(LocalDateTime.now());
        notification.setType(NotificationType.RIDE_REQUEST);
        
        Notification savedNofication = notificationRepository.save(notification);
        
//    rideService.sendNotificationToDriver(nearestDriver, ride);
        
Ride savedRide = rideRepository.save(ride);
return savedRide;
	}

	@Override
public Ride createRideRequest(User user, Driver nearestDriver, double pickupLatitude, 
        double pickupLongitude, double destinationLatitude, double destinationLongitude,
        String pickupArea, String destinationArea, Long expectedDuration) {
    
    Ride ride = new Ride();
    
    ride.setDriver(nearestDriver);
    logger.debug("Driver assigned to the ride: {}", nearestDriver.getId());

    // Initialize users set and add the requesting user
    Set<User> users = new HashSet<>();
    users.add(user);
    ride.setUsers(users);
    logger.debug("User assigned to the ride: {}", user.getId());

    ride.setPickupLatitude(pickupLatitude);
    ride.setPickupLongitude(pickupLongitude);
    ride.setDestinationLatitude(destinationLatitude);
    ride.setDestinationLongitude(destinationLongitude);
    ride.setStatus(RideStatus.REQUESTED);
    ride.setPickupArea(pickupArea);
    ride.setDestinationArea(destinationArea);
    ride.setExpectedDuration(expectedDuration);

    Ride savedRide = rideRepository.save(ride);
    logger.info("Ride created and saved with ID: {}", savedRide.getId());

    return savedRide;
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
		
        //notification.setUser(ride.getUser());;
        notification.setMessage("Your Ride Is Conformed Driver Will Reach Soon At Your Pickup Location");
        notification.setRide(ride);
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
		
        //notification.setUser(ride.getUser());;
        notification.setMessage("Driver Reached At Your Pickup Location");
        notification.setRide(ride);
        notification.setTimestamp(LocalDateTime.now());
        notification.setType(NotificationType.RIDE_CONFIRMATION);
		
        Notification savedNofication = notificationRepository.save(notification);
		
	}

	

	@Override
	public void completeRide(Integer rideId) throws RideException {
		Ride ride=findRideById(rideId);
		
		ride.setStatus(RideStatus.COMPLETED);
		ride.setEndTime(LocalDateTime.now());;
		

		double distence=calculaters.calculateDistance(ride.getPickupArea(),ride.getDestinationArea());
		

		LocalDateTime start=ride.getStartTime();
		System.out.println("Start time is ------------" + start);

		LocalDateTime end=ride.getEndTime();
		System.out.println("end time is ---------"+ end);
		Duration duration = Duration.between(start, end);
		long secs = duration.toSeconds(); //made change here
		System.out.println("actual duration is -------" + duration);
		ride.setDuration(secs);


		// Fetch the expected duration using the MapService
try {
    // Call the MapService to get the distance and duration
    DistanceTime distanceTime = mapService.getDistanceTime(ride.getPickupArea(), ride.getDestinationArea());
    
    // Get the duration text, e.g., "10 mins"
    String durationText = distanceTime.getTime(); // Get text value
    System.out.println("Expected Duration (text): " + durationText);

    // Extract numeric value from text (e.g., "10 mins" -> 10)
    long expectedDurationInMinutes = Long.parseLong(durationText.replaceAll("[^0-9]", "")); // Parse directly to long
    
    // Set the expected duration
    ride.setExpectedDuration(expectedDurationInMinutes); // Save expected duration
    System.out.println("Expected Duration (minutes): " + expectedDurationInMinutes);
} catch (Exception e) {
    System.out.println("Failed to fetch expected duration: " + e.getMessage());
}


		System.out.println("actual duration ------- "+ secs);
		double fare=calculaters.calculateFare(distence);

		
		
		ride.setDistance(Math.round(distence * 100.0) / 100.0);
		ride.setFare((int) Math.round(fare));
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
		
       // notification.setUser(ride.getUser());;
        notification.setMessage("Driver Reached At Your Pickup Location");
        notification.setRide(ride);
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
		
		List<Driver> availableDrivers=driverService.getAvailableDrivers(ride.getPickupArea(), 5,ride);
		
		Driver nearestDriver=driverService.findNearestDriver(availableDrivers, ride.getPickupArea());
		
		
		ride.setDriver(nearestDriver);
		
		rideRepository.save(ride);
		
	}
	@Override
	public DistanceTime getDistanceTimeBetweenDriverAndPickupArea(String driverArea, String pickupArea) throws Exception {
        return mapService.getDistanceTime(driverArea, pickupArea);
    }


	@Transactional
    public Ride createOrJoinCarpoolRide(String useremail, String pickupArea, String destinationArea) {
    final double RADIUS = 5.0; // Static radius of 5 km

    String email = jwtUtil.getEmailFromToken(useremail);

    // Step 1: Fetch User by Email
    User user = userRepository.findByEmail(email);
    if (user == null) {
        throw new RuntimeException("User not found with email: " + email);
    }

    // Step 2: Find if an existing ride has space
    List<Ride> matchingRides = rideRepository.findMatchingRides(pickupArea, destinationArea,RideStatus.REQUESTED);
    for (Ride ride : matchingRides) {
        if (ride.getUsers().size() < 3) {  // Ensure ride isn't full
            ride.getUsers().add(user);
            rideRepository.save(ride);
            return ride;
        }
    }

    // Step 3: Find available drivers within the static 5 km radius
    List<Driver> availableDrivers = driverService.getAvailableDrivers(pickupArea, RADIUS, new Ride());
    if (availableDrivers.isEmpty()) {
        throw new RuntimeException("No available drivers within " + RADIUS + " km radius.");
    }

    // Step 4: Select the nearest driver
    Driver nearestDriver = driverService.findNearestDriver(availableDrivers, pickupArea);
    if (nearestDriver == null) {
        throw new RuntimeException("Could not find the nearest driver.");
    }

    // Step 5: Create a new ride
    Ride newRide = new Ride();
    newRide.setUsers(new HashSet<>(Set.of(user)));  // Add first user
    newRide.setDriver(nearestDriver);
    newRide.setPickupArea(pickupArea);
    newRide.setDestinationArea(destinationArea);
    newRide.setStatus(RideStatus.REQUESTED);

    return rideRepository.save(newRide);
  }
    @Override
    public List<Ride> findMatchingRides(String pickupArea, String destinationArea, RideStatus status) {
        return rideRepository.findMatchingRides(pickupArea, destinationArea, status);
    }

  @Override
  public void saveRide(Ride ride) {
	rideRepository.save(ride);
  }

}
