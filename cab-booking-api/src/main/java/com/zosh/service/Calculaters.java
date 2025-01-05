package com.zosh.service;

import java.time.LocalDateTime;

import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class Calculaters {
	
	 private static final int EARTH_RADIUS = 6371; // Radius of the Earth in kilometers
	 
//	 a = sin²(Δlat/2) + cos(lat1).cos(lat2).sin²(Δlon/2)
//	 c = 2.atan2(√a, √(1−a))
//	 d = R.c

	 public double calculateDistance(double sourceLat, double sourceLng, double destLat, double destLng) {
		 
		 double dLat = Math.toRadians(destLat - sourceLat);
	     double dLng = Math.toRadians(destLng - sourceLng);
	     double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
	                + Math.cos(Math.toRadians(sourceLat)) * Math.cos(Math.toRadians(destLat))
	                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
	     double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	     double distance = EARTH_RADIUS * c;
	     return distance;
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
