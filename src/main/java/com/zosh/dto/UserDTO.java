package com.zosh.dto;

public class UserDTO {
	
	private Integer Id;
	private String email;
	private String name;
	private String mobile;
	
	public UserDTO() {
		// TODO Auto-generated constructor stub
	}

	public UserDTO(Integer id, String email, String name, String mobile) {
		super();
		Id = id;
		this.email = email;
		this.name = name;
		this.mobile = mobile;
	}

	public Integer getId() {
		return Id;
	}

	public void setId(Integer id) {
		Id = id;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}
	
	

}
