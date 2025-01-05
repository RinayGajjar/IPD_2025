package com.zosh.request;

import com.zosh.modal.License;
import com.zosh.modal.Vehicle;

import jakarta.persistence.OneToOne;

public class DriversSignupRequest {
	
	private String name;
	private String email;
	private String mobile;
	private String password;
	private double latitude;
	private double longitude;
	
	@OneToOne(mappedBy = "driver")
	private License license;
	
	@OneToOne(mappedBy="driver")
	private Vehicle vehicle;
	
	public DriversSignupRequest() {
		// TODO Auto-generated constructor stub
	}

	public DriversSignupRequest(String name, String email, String mobile, String password, double latitude,
			double longitude, License license, Vehicle vehicle) {
		super();
		this.name = name;
		this.email = email;
		this.mobile = mobile;
		this.password = password;
		this.latitude = latitude;
		this.longitude = longitude;
		this.license = license;
		this.vehicle = vehicle;
	}

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public License getLicense() {
		return license;
	}

	public void setLicense(License license) {
		this.license = license;
	}

	public Vehicle getVehicle() {
		return vehicle;
	}

	public void setVehicle(Vehicle vehicle) {
		this.vehicle = vehicle;
	}
	
	

}
