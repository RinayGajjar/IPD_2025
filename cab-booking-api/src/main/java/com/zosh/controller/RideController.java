package com.zosh.controller;


import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.zosh.controller.mapper.DtoMapper;
import com.zosh.dto.RideDTO;
import com.zosh.exception.DriverException;
import com.zosh.exception.RideException;
import com.zosh.exception.UserException;
import com.zosh.modal.DistanceTime;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.request.RideRequest;
import com.zosh.request.StartRideRequest;
import com.zosh.response.MessageResponse;
import com.zosh.ride.domain.RideStatus;
import com.zosh.service.DriverService;
import com.zosh.service.RideService;
import com.zosh.service.UserService;

@RestController
@RequestMapping("/api/rides")
public class RideController {
	
	@Autowired
	private UserService userService;
	
	@Autowired
	private RideService rideService;
	
	@Autowired
	private DriverService driverService;

	private static final Logger logger=LoggerFactory.getLogger(RideController.class);


	@PostMapping("/request")
public ResponseEntity<RideDTO> userRequestRideHandler(@RequestBody RideRequest rideRequest, @RequestHeader("Authorization") String jwt) {
    try {
        logger.info("Start processing the ride request...");

        // Log the incoming JWT token
        logger.info("Incoming JWT: {}", jwt);

        // Retrieve the user based on the JWT token
        User user = userService.findUserByToken(jwt);
        if (user == null) {
            logger.error("User not found for JWT token: {}", jwt);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        logger.info("User ID: {}", user.getId());

        String pickupArea = rideRequest.getPickupArea();
        String destinationArea = rideRequest.getDestinationArea();

        // Step 1: Wait for up to 2 minutes for carpooling users
        long startTime = System.currentTimeMillis();
        long maxWaitTime = 120_000; // 2 minutes in milliseconds
        Ride carpoolRide = null;

        while (System.currentTimeMillis() - startTime < maxWaitTime) {
            // Check if any other users have the same pickup & destination area
            List<Ride> existingCarpoolRides = rideService.findMatchingRides(pickupArea, destinationArea, RideStatus.REQUESTED);
            
            for (Ride ride : existingCarpoolRides) {
                if (ride.getUsers().size() < 3) {  // Max 3 users per ride
                    logger.info("Carpool ride found, adding user ID: {} to existing ride.", user.getId());
                    ride.getUsers().add(user);
                    rideService.saveRide(ride);
                    carpoolRide = ride;
                    break;
                }
            }

            if (carpoolRide != null) {
                break; // Exit loop if a carpool ride is found
            }

            Thread.sleep(10_000); // Wait 10 seconds before checking again
        }

        // Step 2: If carpooling users are found, return the carpool ride
        if (carpoolRide != null) {
            RideDTO rideDto = DtoMapper.toRideDto(carpoolRide);
            return new ResponseEntity<>(rideDto, HttpStatus.ACCEPTED);
        }

        // Step 3: If no carpooling users found within 2 minutes, request a normal ride
        logger.info("No carpooling users found within 2 minutes, requesting a normal ride.");
        Ride ride = rideService.requestRide(rideRequest, user);
        RideDTO rideDto = DtoMapper.toRideDto(ride);

        return new ResponseEntity<>(rideDto, HttpStatus.ACCEPTED);

    } catch (InterruptedException e) {
        logger.error("Thread interrupted while waiting for carpooling users", e);
        Thread.currentThread().interrupt();
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
        logger.error("Error occurred while processing the ride request", e);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
	
    // @PostMapping("/request")
    // public ResponseEntity<RideDTO> userRequestRideHandler(@RequestBody RideRequest rideRequest, @RequestHeader("Authorization") String jwt) {
    //     try {
    //         logger.info("Start processing the ride request...");
            
    //         // Log the incoming JWT token
    //         logger.info("Incoming JWT: {}", jwt);

    //         // Retrieve the user based on the JWT token
    //         User user = userService.findUserByToken(jwt);
    //         if (user == null) {
    //             logger.error("User not found for JWT token: {}", jwt);
    //             return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    //         }
    //         logger.info("User ID: {}", user.getId());

    //         // Process the ride request
    //         Ride ride = rideService.requestRide(rideRequest, user);
    //         logger.info("Ride requested successfully for user ID: {}", user.getId());

    //         // Convert the ride to a DTO
    //         RideDTO rideDto = DtoMapper.toRideDto(ride);
    //         logger.info("RideDTO created successfully for user ID: {}", user.getId());

    //         return new ResponseEntity<>(rideDto, HttpStatus.ACCEPTED);

    //     } catch (Exception e) {
    //         // Log the exception with detailed information
    //         logger.error("Error occurred while processing the ride request", e);

    //         // Optionally, return a more specific HTTP status or error message
    //         return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    //     }
    // }
	
	@PutMapping("/{rideId}/accept")
	public ResponseEntity<MessageResponse> acceptRideHandler(@PathVariable Integer rideId) throws UserException, RideException{
		
		rideService.acceptRide(rideId);
		
		MessageResponse res=new MessageResponse("Ride Accepted By Driver");
		
		return new ResponseEntity<>(res,HttpStatus.ACCEPTED);
	}
	
	@PutMapping("/{rideId}/decline")
	public ResponseEntity<MessageResponse> declineRideHandler(@RequestHeader("Authorization") String jwt, @PathVariable Integer rideId) 
			throws UserException, RideException, DriverException{
		
		Driver driver = driverService.getReqDriverProfile(jwt);
		
		rideService.declineRide(rideId, driver.getId());
		
		MessageResponse res=new MessageResponse("Ride decline By Driver");
		
		return new ResponseEntity<>(res,HttpStatus.ACCEPTED);
	}
	
	@PutMapping("/{rideId}/start")
	public ResponseEntity<MessageResponse> rideStartHandler(@PathVariable Integer rideId, @RequestBody  StartRideRequest req) throws UserException, RideException{
		
		rideService.startRide(rideId,req.getOtp());
		
		MessageResponse res=new MessageResponse("Ride is started");
		
		return new ResponseEntity<>(res,HttpStatus.ACCEPTED);
	}

	@PutMapping("/{rideId}/complete")
	public ResponseEntity<MessageResponse> rideCompleteHandler(@PathVariable Integer rideId) throws UserException, RideException{
		
		rideService.completeRide(rideId);
		
		MessageResponse res=new MessageResponse("Ride Is Completed Thank You For Booking Cab");
		
		return new ResponseEntity<>(res,HttpStatus.ACCEPTED);
	}
	
	@GetMapping("/{rideId}")
	public ResponseEntity<RideDTO> findRideByIdHandler(@PathVariable Integer rideId, @RequestHeader("Authorization") String jwt) throws UserException, RideException{
		System.out.println("error--------------------------A-----------------------");
		User user =userService.findUserByToken(jwt);
		if(user==null) {
			throw new UserException("User Not Found");
		}
		System.out.println("user email --------------" + user.getEmail());
		System.out.println("error----------------------B--------------------");	
		Ride ride =rideService.findRideById(rideId);
		System.out.println("error----------------------C--------------------");
		RideDTO rideDto=DtoMapper.toRideDto(ride);
		if(rideDto==null || rideDto.getOtp()==0){
			throw new RideException("Ride Not Found");
		}
		System.out.println("error----------------------D--------------------");
		return new ResponseEntity<RideDTO>(rideDto,HttpStatus.ACCEPTED);
	}

	@GetMapping("/distance-time")
    public ResponseEntity<DistanceTime> getDistanceTimeBetweenDriverAndPickupArea(
            @RequestParam String driverArea, @RequestParam String pickupArea) {
        try {
            DistanceTime distanceTime = rideService.getDistanceTimeBetweenDriverAndPickupArea(driverArea, pickupArea);
            return new ResponseEntity<>(distanceTime, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("Error occurred while fetching distance and time", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
//	complete all ride apis
}
