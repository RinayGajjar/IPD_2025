package com.zosh.config;

import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.crypto.SecretKey;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Service;

import com.zosh.modal.User;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtUtil {
	
	SecretKey key=Keys.hmacShaKeyFor(JwtSecurityContext.JWT_KEY.getBytes());
	
	public String generateJwtToken(Authentication authentication) {
		
		
		
		String jwt=Jwts.builder().setIssuer("Code With Zosh")
				.setIssuedAt(new Date())
				.setExpiration(new Date(new Date().getTime()+86400000))
				.claim("email", authentication.getName())
				.signWith(key)
				.compact();
		
		return jwt;
	}
	
	public String getEmailFromToken(String token) {
		System.out.println("before claims ----------- ");

		token=token.substring(7);
		
		Claims claims= Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
		
		String email= String.valueOf(claims.get("email"));
		
		return email;
    }
	
	public String populateAuthorities(Collection<? extends GrantedAuthority> collection) {
		Set<String> authoritieSet=new HashSet<>();
		for(GrantedAuthority authority:collection) {
			authoritieSet.add(authority.getAuthority());
		}
		return String.join(",", authoritieSet);
	}

}
