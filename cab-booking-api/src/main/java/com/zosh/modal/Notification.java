package com.zosh.modal;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.zosh.ride.domain.NotificationType;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;

@Entity
public class Notification {
	
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer id;
	
	@ManyToOne(cascade = CascadeType.ALL)
	private User user;
	
	@ManyToOne(cascade = CascadeType.ALL)
	private Driver driver;
	
	@JsonIgnore
	@ManyToOne(cascade = CascadeType.ALL)
	private Ride rid;
	
	private String message;
	
	private NotificationType type;

	private LocalDateTime timestamp;
	
	public Notification() {
		// TODO Auto-generated constructor stub
	}

	public Notification(Integer id, User user, Driver driver, Ride rid, String message, NotificationType type,
			LocalDateTime timestamp) {
		super();
		this.id = id;
		this.user = user;
		this.driver = driver;
		this.rid = rid;
		this.message = message;
		this.type = type;
		this.timestamp = timestamp;
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
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

	public Ride getRid() {
		return rid;
	}

	public void setRid(Ride rid) {
		this.rid = rid;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public NotificationType getType() {
		return type;
	}

	public void setType(NotificationType type) {
		this.type = type;
	}

	public LocalDateTime getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(LocalDateTime timestamp) {
		this.timestamp = timestamp;
	}
	

}
