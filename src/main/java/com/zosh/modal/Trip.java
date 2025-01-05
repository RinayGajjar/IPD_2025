package com.zosh.modal;

import java.sql.Date;

import org.springframework.data.jpa.repository.Temporal;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;



@Entity
	public class Trip {

	    @Id
	    @GeneratedValue(strategy = GenerationType.IDENTITY)
	    private Long id;

	    @ManyToOne
	    private User user;

	    @ManyToOne
	    private Driver driver;

	    private Date startTime;

	    private Date endTime;

	    private double startLat;

	    private double startLong;

	    private double endLat;

	    private double endLong;

	    private double distance;

	    private double fare;

	    // Constructors, getters, and setters
	    
	    public Trip() {
			// TODO Auto-generated constructor stub
		}

		public Trip(Long id, User user, Driver driver, Date startTime, Date endTime, double startLat, double startLong,
				double endLat, double endLong, double distance, double fare) {
			super();
			this.id = id;
			this.user = user;
			this.driver = driver;
			this.startTime = startTime;
			this.endTime = endTime;
			this.startLat = startLat;
			this.startLong = startLong;
			this.endLat = endLat;
			this.endLong = endLong;
			this.distance = distance;
			this.fare = fare;
		}

		public Long getId() {
			return id;
		}

		public void setId(Long id) {
			this.id = id;
		}

		public User getUser() {
			return user;
		}

		public void setUser(User user) {
			this.user = user;
		}

		public Driver getDriver() {
			return driver;
		}

		public void setDriver(Driver driver) {
			this.driver = driver;
		}

		public Date getStartTime() {
			return startTime;
		}

		public void setStartTime(Date startTime) {
			this.startTime = startTime;
		}

		public Date getEndTime() {
			return endTime;
		}

		public void setEndTime(Date endTime) {
			this.endTime = endTime;
		}

		public double getStartLat() {
			return startLat;
		}

		public void setStartLat(double startLat) {
			this.startLat = startLat;
		}

		public double getStartLong() {
			return startLong;
		}

		public void setStartLong(double startLong) {
			this.startLong = startLong;
		}

		public double getEndLat() {
			return endLat;
		}

		public void setEndLat(double endLat) {
			this.endLat = endLat;
		}

		public double getEndLong() {
			return endLong;
		}

		public void setEndLong(double endLong) {
			this.endLong = endLong;
		}

		public double getDistance() {
			return distance;
		}

		public void setDistance(double distance) {
			this.distance = distance;
		}

		public double getFare() {
			return fare;
		}

		public void setFare(double fare) {
			this.fare = fare;
		}

		@Override
		public String toString() {
			return "Trip [id=" + id + ", user=" + user + ", driver=" + driver + ", startTime=" + startTime
					+ ", endTime=" + endTime + ", startLat=" + startLat + ", startLong=" + startLong + ", endLat="
					+ endLat + ", endLong=" + endLong + ", distance=" + distance + ", fare=" + fare + "]";
		}
	    
	    
	}



