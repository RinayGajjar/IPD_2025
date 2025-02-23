package com.zosh.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.zosh.modal.Ride;
import com.zosh.ride.domain.RideStatus;

public interface RideRepository extends JpaRepository<Ride, Integer> {
	
	@Query("SELECT R FROM Ride R WHERE R.status=REQUESTED AND R.driver.ID=:driverId")
	public Ride getDriversCurrentRide(@Param("driverId") Integer driverId);


    @Query("SELECT R FROM Ride R WHERE R.pickupArea = :pickupArea AND R.destinationArea = :destinationArea AND R.status = :status")
    public List<Ride> findMatchingRides(
        @Param("pickupArea") String pickupArea, 
        @Param("destinationArea") String destinationArea, 
        @Param("status") RideStatus status
    );

}
