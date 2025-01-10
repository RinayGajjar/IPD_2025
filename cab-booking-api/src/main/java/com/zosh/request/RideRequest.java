package com.zosh.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.zosh.modal.DistanceTime;
import com.zosh.modal.Ride;
import com.zosh.modal.User;
import com.zosh.service.MapService;

public class RideRequest {
	
	// private double pickupLongitude;
	// private double pickupLatitude;
	// private double destinationLongitude;
	// private double destinationLatitude;
	private String pickupArea;
	private String destinationArea;
	@JsonProperty("expectedDuration")
	private long expectedDuration;
	

	public RideRequest() {
		// TODO Auto-generated constructor stub
	}
	
	public RideRequest(String pickupArea, String destinationArea) {
		super();
		// this.pickupLongitude = pickupLongitude;
		// this.pickupLatitude = pickupLatitude;
		// this.destinationLongitude = destinationLongitude;
		// this.destinationLatitude = destinationLatitude;
		this.pickupArea = pickupArea;
		this.destinationArea = destinationArea;
	}


	public long getExpectedDuration() {
		if(pickupArea != null && destinationArea != null) {
            try {
                MapService mapService = new MapService();
                DistanceTime distanceTime = mapService.getDistanceTime(pickupArea, destinationArea);
                String durationText = distanceTime.getTime();
                return Long.parseLong(durationText.replaceAll("[^0-9]", ""));
            } catch (Exception e) {
                System.out.println("Failed to fetch expected duration: " + e.getMessage());
            }
        }
        return 0; // Default if computation fails
	}
	public String getPickupArea() {
		return pickupArea;
	}

	public void setPickupArea(String pickupArea) {
		this.pickupArea = pickupArea;
	}

	public String getDestinationArea() {
		return destinationArea;
	}

	public void setDestinationArea(String destinationArea) {
		this.destinationArea = destinationArea;
	}

	// public double getPickupLatitude() {
	// 	return pickupLatitude;
	// }

	// public void setPickupLatitude(double pickupLatitude) {
	// 	this.pickupLatitude = pickupLatitude;
	// }

	// public double getPickupLongitude() {
	// 	return pickupLongitude;
	// }
	// public void setPickupLongitude(double pickupLongitude) {
	// 	this.pickupLongitude = pickupLongitude;
	// }
	
	// public double getDestinationLongitude() {
	// 	return destinationLongitude;
	// }
	// public void setDestinationLongitude(double destinationLongitude) {
	// 	this.destinationLongitude = destinationLongitude;
	// }
	// public double getDestinationLatitude() {
	// 	return destinationLatitude;
	// }
	// public void setDestinationLatitude(double destinationLatitude) {
	// 	this.destinationLatitude = destinationLatitude;
	// }


	

}
