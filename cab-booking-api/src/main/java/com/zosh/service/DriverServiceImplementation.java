package com.zosh.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.zosh.config.JwtUtil;
import com.zosh.exception.DriverException;
import com.zosh.modal.Driver;
import com.zosh.modal.License;
import com.zosh.modal.Ride;
import com.zosh.modal.Vehicle;
import com.zosh.repository.DriverRepository;
import com.zosh.repository.LicenseRepository;
import com.zosh.repository.RideRepository;
import com.zosh.repository.VehicleRepository;
import com.zosh.request.DriversSignupRequest;
import com.zosh.ride.domain.RideStatus;
import com.zosh.ride.domain.UserRole;

@Service
public class DriverServiceImplementation implements DriverService {
	
	@Autowired
	private DriverRepository driverRepository;
	
	@Autowired
	private Calculaters distenceCalculator;
	
	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Autowired
	private JwtUtil jwtUtil;
	
	@Autowired
	private VehicleRepository vehicleRepository;
	
	@Autowired
	private LicenseRepository licenseRepository;
	
	@Autowired
	private RideRepository rideRepository;

	@Override
	public Driver createDriverFromRequest(DriversSignupRequest request) {
		// TODO Auto-generated method stub
		Driver driver=new Driver();
		driver.setDriverArea(request.getDriverArea());
		return driver;
	}
	@Override
	public List<Driver> getAvailableDrivers(String ride_pickupArea, double radius, Ride ride) {
		List<Driver> allDrivers=driverRepository.findAll();
		
		
		List<Driver> availableDriver=new ArrayList<>();
		
		
		for(Driver driver:allDrivers) {
			
			if(driver.getCurrentRide()!=null && driver.getCurrentRide().getStatus()!=RideStatus.COMPLETED 
					) {
				
				continue;
			}
			if(ride.getDeclinedDrivers().contains(driver.getId())) {
				System.out.println("its containes");
				continue;
			}

			
			
			
			double distence=distenceCalculator.calculateDistance(ride_pickupArea,driver.getDriverArea());
			System.out.println("ride is -------" + ride_pickupArea + "driver is --------------" + driver.getDriverArea());
			//the main problem is that if the distance of driver is >radius(5) then available driver is not added because of which it causes null problem 
			 if(distence<=radius) {
				availableDriver.add(driver);
			 }
		}
		
		return availableDriver;
	}

	@Override
	public Driver findNearestDriver(List<Driver> availableDrivers, String ride_pickupArea) {
		// Ride ride=new Ride();
		double min=Double.MAX_VALUE;;
		Driver nearestDriver = null;
		System.out.println("avaialable drivers are "  + availableDrivers);
//		List<Driver> drivers=new ArrayList<>();
//		double minAuto
		
		for(Driver driver : availableDrivers) {
			System.out.println("ride pickup area is  ------------" +ride_pickupArea + "driver area is ---------------" + driver.getDriverArea());
			double distence=distenceCalculator.calculateDistance(ride_pickupArea,driver.getDriverArea());
			System.out.println("distance of driver is ---------------------------" + distence);
			
			if(min>distence) {
				min=distence;
				nearestDriver=driver;
			}
		}
		
		return nearestDriver;
	}

	@Override
	public Driver registerDriver(DriversSignupRequest driversSignupRequest) {

		License license=driversSignupRequest.getLicense();
		Vehicle vehicle=driversSignupRequest.getVehicle();
		
		License createdLicense=new License();
		
		createdLicense.setLicenseState(license.getLicenseState());
		createdLicense.setLicenseNumber(license.getLicenseNumber());
		createdLicense.setLicenseExpirationDate(license.getLicenseExpirationDate());
		createdLicense.setId(license.getId());
		
		License savedLicense=licenseRepository.save(createdLicense);
		
		Vehicle createdVehicle = new Vehicle();
		
		createdVehicle.setCapacity(vehicle.getCapacity());
		createdVehicle.setColor(vehicle.getColor());
		createdVehicle.setId(vehicle.getId());
		createdVehicle.setLicensePlate(vehicle.getLicensePlate());
		createdVehicle.setMake(vehicle.getMake());
		createdVehicle.setModel(vehicle.getModel());
		createdVehicle.setYear(vehicle.getYear());
		
		Vehicle savedVehicle = vehicleRepository.save(createdVehicle);
		
		Driver driver = new Driver();
		
		String encodedPassword = passwordEncoder.encode(driversSignupRequest.getPassword());
		
		driver.setEmail(driversSignupRequest.getEmail());
		driver.setName(driversSignupRequest.getName());
		driver.setMobile(driversSignupRequest.getMobile());
		driver.setDriverArea(driversSignupRequest.getDriverArea());
		driver.setPassword(encodedPassword);
		driver.setLicense(savedLicense);
		driver.setVehicle(savedVehicle);
		driver.setRole(UserRole.DRIVER) ;
		driver.setDriverArea(driver.getDriverArea());
		
		
		Driver createdDriver = driverRepository.save(driver);
		
		savedLicense.setDriver(createdDriver);
		savedVehicle.setDriver(createdDriver);
		
		licenseRepository.save(savedLicense);
		vehicleRepository.save(savedVehicle);
		
		return createdDriver;
			
	}

	@Override
	public Driver getReqDriverProfile(String jwt) throws DriverException {
		String email=jwtUtil.getEmailFromToken(jwt);
		Driver driver= driverRepository.findByEmail(email);
		if(driver==null) {
			throw new DriverException("driver not exist with email " + email);
		}
		
		return driver;
		
	}

	@Override
	public Ride getDriversCurrentRide(Integer driverId) throws DriverException {
		Driver driver = findDriverById(driverId);
		return driver.getCurrentRide();
	}

	@Override
	public List<Ride> getAllocatedRides(Integer driverId) throws DriverException {
		List<Ride> allocatedRides=driverRepository.getAllocatedRides(driverId);
		return allocatedRides;
	}

	@Override
	public Driver findDriverById(Integer driverId) throws DriverException {
		Optional<Driver> opt=driverRepository.findById(driverId);
		if(opt.isPresent()) {
			return opt.get();
		}
		throw new DriverException("driver not exist with id "+driverId);
	}

	@Override
	public List<Ride> completedRids(Integer driverId) throws DriverException {
		List <Ride> completedRides=driverRepository.getCompletedRides(driverId);
		return completedRides;
	}
}
