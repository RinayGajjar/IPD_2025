package com.zosh.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.zosh.exception.DriverException;
import com.zosh.modal.Driver;
import com.zosh.modal.Ride;
import com.zosh.service.DriverService;

@RestController
@RequestMapping("/api/drivers")
public class DriverController {
	
	@Autowired
	private DriverService driverService;
	
	@GetMapping("/profile")
	public ResponseEntity<Driver> getReqDriverProfileHandler(@RequestHeader("Authorization") String jwt) throws DriverException {

		// ok
		
		Driver driver = driverService.getReqDriverProfile(jwt);
		
		return new ResponseEntity<Driver>(driver,HttpStatus.ACCEPTED);
	}
	
	@GetMapping("/{driverId}/current_ride")
	public ResponseEntity<Ride> getDriversCurrentRideHandler(@PathVariable Integer driverId) throws DriverException{
		
		Ride ride=driverService.getDriversCurrentRide(driverId);
		
		return new ResponseEntity<Ride>(ride,HttpStatus.ACCEPTED);
	}

	@GetMapping("/{driverId}/allocated")
	public ResponseEntity<Ride> getAllocatedRidesHandler(@PathVariable Integer driverId) throws DriverException{
	    Ride ride=driverService.getAllocatedRides(driverId);
		
		return new ResponseEntity<>(ride,HttpStatus.ACCEPTED);
	}
	
	@GetMapping("/rides/completed")
	public ResponseEntity<List<Ride>> getcompletedRidesHandler(@RequestHeader("Authorization") String jwt) throws DriverException{
		
		Driver driver = driverService.getReqDriverProfile(jwt);
		
		List<Ride> rides=driverService.completedRids(driver.getId());
		
		return new ResponseEntity<>(rides,HttpStatus.ACCEPTED);
	}
	
	//To be Testesd
	@PutMapping("/update-area")
    public ResponseEntity<String> updateDriverArea(@RequestHeader("Authorization") String jwt, @RequestBody String newArea) {
        try {
            driverService.updateDriverArea(jwt, newArea);
            return ResponseEntity.ok("Driver area updated successfully");
        } catch (DriverException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

}
