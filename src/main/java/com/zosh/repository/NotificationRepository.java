package com.zosh.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.zosh.modal.Notification;

public interface NotificationRepository extends JpaRepository<Notification, Integer>{

}
