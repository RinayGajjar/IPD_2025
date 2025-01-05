package com.zosh.dto;

import java.time.Duration;
import java.time.LocalDateTime;

import com.zosh.modal.PaymentDetails;
import com.zosh.ride.domain.RideStatus;

public class RideDTO {
	
	    private Integer id;
	    private UserDTO user;
	    private DriverDTO driver;
	    private double pickupLatitude;
	    private double pickupLongitude;
	    private double destinationLatitude;
	    private double destinationLongitude;
		private String pickupArea;
		private String destinationArea;
	    private double distance;
	    private long duration;
	    private RideStatus status;
	    private LocalDateTime startTime;
	    private LocalDateTime endTime;
	    private double fare;
	    private PaymentDetails paymentDetails;
	    private int otp;
	    
	    public RideDTO() {
			// TODO Auto-generated constructor stub
		}

		public int getOtp() {
			return otp;
		}

		public void setOtp(int otp) {
			this.otp = otp;
		}

		public PaymentDetails getPaymentDetails() {
			return paymentDetails;
		}

		public void setPaymentDetails(PaymentDetails paymentDetails) {
			this.paymentDetails = paymentDetails;
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

		public Integer getId() {
			return id;
		}

		public void setId(Integer id) {
			this.id = id;
		}

		public UserDTO getUser() {
			return user;
		}

		public void setUser(UserDTO user) {
			this.user = user;
		}

		public DriverDTO getDriver() {
			return driver;
		}

		public void setDriver(DriverDTO driver) {
			this.driver = driver;
		}

		public double getPickupLatitude() {
			return pickupLatitude;
		}

		public void setPickupLatitude(double pickupLatitude) {
			this.pickupLatitude = pickupLatitude;
		}

		public double getPickupLongitude() {
			return pickupLongitude;
		}

		public void setPickupLongitude(double pickupLongitude) {
			this.pickupLongitude = pickupLongitude;
		}

		public double getDestinationLatitude() {
			return destinationLatitude;
		}

		public void setDestinationLatitude(double destinationLatitude) {
			this.destinationLatitude = destinationLatitude;
		}

		public double getDestinationLongitude() {
			return destinationLongitude;
		}

		public void setDestinationLongitude(double destinationLongitude) {
			this.destinationLongitude = destinationLongitude;
		}

		public double getDistance() {
			return distance;
		}

		public void setDistance(double distance) {
			this.distance = distance;
		}

		public long getDuration() {
			return duration;
		}

		public void setDuration(long duration) {
			this.duration = duration;
		}

		public RideStatus getStatus() {
			return status;
		}

		public void setStatus(RideStatus status) {
			this.status = status;
		}

		public LocalDateTime getStartTime() {
			return startTime;
		}

		public void setStartTime(LocalDateTime startTime) {
			this.startTime = startTime;
		}

		public LocalDateTime getEndTime() {
			return endTime;
		}

		public void setEndTime(LocalDateTime endTime) {
			this.endTime = endTime;
		}

		public double getFare() {
			return fare;
		}

		public void setFare(double fare) {
			this.fare = fare;
		}
	    
	  

}
