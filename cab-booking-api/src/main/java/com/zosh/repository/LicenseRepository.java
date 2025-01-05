package com.zosh.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.zosh.modal.License;

public interface LicenseRepository extends JpaRepository<License, Integer> {

}
