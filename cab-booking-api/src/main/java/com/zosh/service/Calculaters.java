package com.zosh.service;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zosh.modal.DistanceTime;
import com.zosh.modal.GoogleDistanceMatrixResponse.Distance;

import java.time.Duration;

@Service
public class Calculaters {
	
	@Autowired
	MapService mapService;
	private static final int EARTH_RADIUS = 6371; // Radius of the Earth in kilometers 
//	 a = sin²(Δlat/2) + cos(lat1).cos(lat2).sin²(Δlon/2)
//	 c = 2.atan2(√a, √(1−a))
//	 d = R.c 

public double calculateDistance(String pickup, String destination) {
	
    try {
        DistanceTime distanceTime = mapService.getDistanceTime(pickup, destination);
        String distanceText = distanceTime.getDistance(); // Example: "12.3 km"
        double distance = Double.parseDouble(distanceText.split(" ")[0]); // Extract numeric value
        return distance; // Return distance in kilometers
    } catch (Exception e) {
        e.printStackTrace();
        return 0.0; // Return 0.0 in case of an error
    }
}
	 
	 
	 public long calculateDuration(LocalDateTime startTime, LocalDateTime endTime) {
	        Duration duration = Duration.between(startTime, endTime);
	        return duration.getSeconds();
	    }
	 
	 public double calculateFare(double distance) {
	        double baseFare = 11;
	        double totalFare=baseFare*distance;
	        return totalFare;
	    }

}
