package com.zosh.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.zosh.modal.Ride;
import com.zosh.modal.User;

public interface UserRepository extends JpaRepository<User, Long> {

	public User findByEmail(String email);
	
	// @Query("SELECT R FROM Ride R WHERE R.status = ACCEPTED AND R.user.id = :userId ORDER BY R.id DESC")
    // List<Ride> getAllocatedRides(@Param("userId") Integer userId);


	// @Query("SELECT R FROM Ride R where R.status=COMPLETED AND R.user.Id=:userId ORDER BY R.endTime DESC")
	// public List<Ride> getCompletedRides(@Param("userId")Long userId);
}
