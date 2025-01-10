package com.zosh.request;

import com.zosh.modal.License;
import com.zosh.modal.Vehicle;

import jakarta.persistence.OneToOne;

public class DriversSignupRequest {
	
	private String name;
	private String email;
	private String mobile;
	private String password;
	private String driverArea;
	


	@OneToOne(mappedBy = "driver")
	private License license;
	
	@OneToOne(mappedBy="driver")
	private Vehicle vehicle;
	
	public DriversSignupRequest() {
		// TODO Auto-generated constructor stub
	}

	public DriversSignupRequest(String name, String email, String mobile, String password, 
	String driverArea, License license, Vehicle vehicle) {
		super();
		this.name = name;
		this.email = email;
		this.mobile = mobile;
		this.password = password;
		this.driverArea=driverArea;
		this.license = license;
		this.vehicle = vehicle;
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
	public String getDriverArea() {
		return driverArea;
	}

	public void setDriverArea(String driverArea) {
		this.driverArea = driverArea;
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
