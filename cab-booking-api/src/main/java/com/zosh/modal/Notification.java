package com.zosh.modal;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.zosh.ride.domain.NotificationType;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
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
    @ManyToOne(cascade = CascadeType.PERSIST)
    @JoinColumn(name = "ride_id")  // Join column to link to Ride entity
    private Ride ride;

    private String message;

    private NotificationType type;

    private LocalDateTime timestamp;

    // Default constructor
    public Notification() {
        // Default constructor
    }

    // Getters and Setters
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

    public Ride getRide() {
        return ride;
    }

    public void setRide(Ride ride) {
        this.ride = ride;
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

    @Override
    public String toString() {
        return "Notification [id=" + id + ", user=" + user + ", driver=" + driver + ", ride=" + ride + ", message="
                + message + ", type=" + type + ", timestamp=" + timestamp + "]";
    }
}
