package com.zosh.response;

import com.zosh.ride.domain.UserRole;

public class JwtResponce {
	
	private String jwt;
	private String message;
	private boolean isAuthenticated;
	private boolean isError;
	private String errorDetails;
	private UserRole type;
	
	
	public JwtResponce() {
		// TODO Auto-generated constructor stub
	}

	public JwtResponce(String jwt, String message, boolean isAuthenticated, boolean isError, String errorDetails,
			UserRole type) {
		super();
		this.jwt = jwt;
		this.message = message;
		this.isAuthenticated = isAuthenticated;
		this.isError = isError;
		this.errorDetails = errorDetails;
		this.type = type;
	}

	public UserRole getType() {
		return type;
	}

	public void setType(UserRole type) {
		this.type = type;
	}

	public String getErrorDetails() {
		return errorDetails;
	}

	public String getJwt() {
		return jwt;
	}


	public void setJwt(String jwt) {
		this.jwt = jwt;
	}


	public String getMessage() {
		return message;
	}


	public void setMessage(String message) {
		this.message = message;
	}


	public boolean isAuthenticated() {
		return isAuthenticated;
	}


	public void setAuthenticated(boolean isAuthenticated) {
		this.isAuthenticated = isAuthenticated;
	}




	public boolean isError() {
		return isError;
	}




	public void setError(boolean isError) {
		this.isError = isError;
	}




	public String isErrorDetails() {
		return errorDetails;
	}




	public void setErrorDetails(String errorDetails) {
		this.errorDetails = errorDetails;
	}


	
	
	
	
	

}
