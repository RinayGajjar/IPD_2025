package com.zosh.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.zosh.modal.Vehicle;

public interface VehicleRepository extends JpaRepository<Vehicle, Integer> {

}
