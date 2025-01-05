package com.zosh.modal;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;

@Entity
public class Review {
	
	
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer id;

	
	@ManyToOne
	private User user;
	
	@ManyToOne
	private Driver driver;
	
	private Integer rating;
	
	private String comment;

	public Review() {
		// TODO Auto-generated constructor stub
	}
	
	public Review(Integer id, User user, Driver driver, Integer rating, String comment) {
		super();
		this.id = id;
		this.user = user;
		this.driver = driver;
		this.rating = rating;
		this.comment = comment;
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

	public Integer getRating() {
		return rating;
	}

	public void setRating(Integer rating) {
		this.rating = rating;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	@Override
	public String toString() {
		return "Review [id=" + id + ", user=" + user + ", driver=" + driver + ", rating=" + rating + ", comment="
				+ comment + "]";
	}
	
	
}
