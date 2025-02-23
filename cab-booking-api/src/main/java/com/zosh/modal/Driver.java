package com.zosh.modal;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.zosh.request.DriversSignupRequest;
import com.zosh.ride.domain.UserRole;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;

@Entity
public class Driver {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    private String name;
    private String email;
    private String mobile;
    private double ratig;
    private String driverArea;
    public String getDriverArea() {
        return driverArea;
    }

    public void setDriverArea(String driverArea) {
        this.driverArea = driverArea;
    }

    private double latitude;
    private double longitude;
    private UserRole role;

    private String password;

    @OneToOne(mappedBy = "driver", cascade = CascadeType.ALL)
    private License license;

    @JsonManagedReference  
    @OneToMany(mappedBy = "driver", cascade = CascadeType.PERSIST, orphanRemoval = false)
    private List<Ride> rides;

    @OneToOne(mappedBy = "driver", cascade = CascadeType.ALL, orphanRemoval = true)
    private Vehicle vehicle;

    @JsonIgnore
    @OneToOne(cascade = CascadeType.PERSIST)
    private Ride currentRide;

    private Integer totalRevenue = 0;

    // Default constructor
    public Driver() {
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public double getRatig() {
        return ratig;
    }

    public void setRatig(double ratig) {
        this.ratig = ratig;
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

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
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

    public List<Ride> getRides() {
        return rides;
    }

    public void setRides(List<Ride> rides) {
        this.rides = rides;
    }

    public Vehicle getVehicle() {
        return vehicle;
    }

    public void setVehicle(Vehicle vehicle) {
        this.vehicle = vehicle;
    }

    public Ride getCurrentRide() {
        return currentRide;
    }

    public void setCurrentRide(Ride currentRide) {
        this.currentRide = currentRide;
    }

    public Integer getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(Integer totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    @Override
    public String toString() {
        return "Driver [id=" + id + ", name=" + name + ", email=" + email + ", mobile=" + mobile + ", ratig=" + ratig
                + ", latitude=" + latitude + ", longitude=" + longitude + ", role=" + role + ", password=" + password
                + ", license=" + license + ", rides=" + rides + ", vehicle=" + vehicle + ", currentRide=" + currentRide
                + ", totalRevenue=" + totalRevenue + "]";
    }
}
