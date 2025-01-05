package com.zosh.config;

import java.io.IOException;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.crypto.SecretKey;
import javax.swing.JComboBox.KeySelectionManager;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class JwtTokenGeneratorFilter extends OncePerRequestFilter {

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		
		if(authentication!=null) {
			SecretKey key=Keys.hmacShaKeyFor(JwtSecurityContext.JWT_KEY.getBytes());
			
			String jwt=
					Jwts.builder()
					.setIssuer("Code with zosh")
					.setIssuedAt(new Date())
					.setExpiration(new Date(new Date().getTime()+ 86400000))
					.claim("authorities", populateAuthorities(authentication.getAuthorities()))
					.claim("email", authentication.getName())
					
					.signWith(key).compact();
			
		}
	}
	
	
	public String populateAuthorities(Collection<? extends GrantedAuthority> collection) {
		
		Set<String> authoritiesSet = new HashSet<>();
        
        for (GrantedAuthority authority : collection) {
            authoritiesSet.add(authority.getAuthority());
        }
        return String.join(",", authoritiesSet);
	}

	
	@Override
	protected boolean shouldNotFilter(HttpServletRequest req) throws ServletException{
	
		return !req.getServletPath().equals("/signin");
	}
	



}

