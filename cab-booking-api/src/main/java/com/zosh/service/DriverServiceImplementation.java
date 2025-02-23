package com.zosh.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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

	private static final Logger logger=LoggerFactory.getLogger(DriverServiceImplementation.class);

	@Override
	public Driver createDriverFromRequest(DriversSignupRequest request) {
		// TODO Auto-generated method stub
		Driver driver=new Driver();
		driver.setDriverArea(request.getDriverArea());
		logger.debug("Driver created with area: {}", request.getDriverArea());
		return driver;
	}
	

	@Override
public List<Driver> getAvailableDrivers(String ride_pickupArea, double radius, Ride ride) {
    logger.info("---------------------------- Finding Drivers Start ----------------------------");

    List<Driver> allDrivers = new ArrayList<>();
    try {
        logger.info("Fetching all drivers from the repository...");
        allDrivers = driverRepository.findAll();
        logger.info("Successfully fetched {} drivers", allDrivers != null ? allDrivers.size() : 0);
    } catch (Exception e) {
        logger.error("Error fetching drivers from repository", e);
        return new ArrayList<>();  // Return an empty list to avoid null issues
    }

    if (allDrivers == null || allDrivers.isEmpty()) {
        logger.warn("No drivers found in the database.");
        return new ArrayList<>();
    }

    List<Driver> availableDriver = new ArrayList<>();
    logger.info("Finding available drivers for pickup area: {}", ride_pickupArea);

    for (Driver driver : allDrivers) {
        if (driver.getCurrentRide() != null && driver.getCurrentRide().getStatus() != RideStatus.COMPLETED) {
            continue;
        }
        if (ride.getDeclinedDrivers().contains(driver.getId())) {
            logger.debug("Driver {} has declined the ride before, skipping.", driver.getId());
            continue;
        }

        double distance = distenceCalculator.calculateDistance(ride_pickupArea, driver.getDriverArea());
        logger.debug("Driver {} distance from pickup area: {}", driver.getId(), distance);

        if (distance <= radius) {
            availableDriver.add(driver);
            logger.info("Driver {} added to available list. Distance: {}", driver.getId(), distance);
        } else {
            logger.warn("Driver {} is too far away ({} km) from pickup area.", driver.getId(), distance);
        }
    }

    if (availableDriver.isEmpty()) {
        logger.error("No drivers found within the specified radius of {} km.", radius);
    } else {
        logger.info("Found {} available drivers within radius.", availableDriver.size());
    }

    logger.info("---------------------------- Finding Drivers End ----------------------------");
    return availableDriver;
}

	@Override
	public Driver findNearestDriver(List<Driver> availableDrivers, String ride_pickupArea) {
		// Ride ride=new Ride();
		double min=Double.MAX_VALUE;;
		Driver nearestDriver = null;
		logger.debug("Finding nearest driver for pickup area: {}", ride_pickupArea);
//		List<Driver> drivers=new ArrayList<>();
//		double minAuto
		
		for(Driver driver : availableDrivers) {
			double distence=distenceCalculator.calculateDistance(ride_pickupArea,driver.getDriverArea());
			logger.debug("Driver {} distance: {}", driver.getId(), distence);
			
			if(min>distence) {
				min=distence;
				nearestDriver=driver;
			}

			if (nearestDriver == null) {
				logger.warn("No nearest driver found.");
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
    public Ride getAllocatedRides(Integer driverId) throws DriverException {
    List<Ride> rides = driverRepository.getAllocatedRides(driverId);

    if (rides == null || rides.isEmpty()) {
        throw new DriverException("No allocated rides found for driverId: " + driverId);
    }

    // Return the first ride (most recent based on query order or additional logic)
    return rides.get(0);
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
	@Override
	public void updateDriverArea(String jwt, String newArea) throws DriverException {
		String email = jwtUtil.getEmailFromToken(jwt);
        Driver optionalDriver = driverRepository.findByEmail(email);
        if (optionalDriver != null) {
            Driver driver = optionalDriver;
            driver.setDriverArea(newArea);
            driverRepository.save(driver);
        } else {
            throw new DriverException("Driver not exist with id " + email);
        }
    }
}
