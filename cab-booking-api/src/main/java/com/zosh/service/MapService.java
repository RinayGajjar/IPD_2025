package com.zosh.service;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.google.gson.Gson;
import com.zosh.modal.Coordinates;
import com.zosh.modal.DistanceTime;
import com.zosh.modal.GoogleAutoCompleteResponse;
import com.zosh.modal.GoogleDistanceMatrixResponse;
import com.zosh.modal.GoogleGeocodeResponse;

import java.util.List;

@Service
public class MapService {

    @Value("${google.maps.api.key}")
    private String googleMapsApiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public Coordinates getAddressCoordinates(String address) throws Exception {
        // Build the URL with query parameters
        String url = UriComponentsBuilder.fromHttpUrl("https://maps.googleapis.com/maps/api/geocode/json")
                .queryParam("address", address)
                .queryParam("key", googleMapsApiKey)
                .toUriString();
    
        // Call the Google Maps API
        GoogleGeocodeResponse response = restTemplate.getForObject(url, GoogleGeocodeResponse.class);
        System.out.println("response is ----------" + response);
        // Log the full JSON response
        System.out.println("Google API Response: " + new Gson().toJson(response));
    
        // Validate response and status
        if (response == null) {
            throw new Exception("Google Maps API response is null");
        }
    
        if (!"OK".equals(response.getStatus())) {
            throw new Exception("Error in API Response: " + response.getStatus());
        }
    
        // Validate results array
        if (response.getResults() == null || response.getResults().isEmpty()) {
            throw new Exception("No results found for the address: " + address);
        }
    
        // Extract location from the first result
        GoogleGeocodeResponse.Result result = response.getResults().get(0);
    
        if (result.getGeometry() == null || result.getGeometry().getLocation() == null) {
            throw new Exception("Invalid location data for the address: " + address);
        }
    
        GoogleGeocodeResponse.Location location = result.getGeometry().getLocation();
    
        // Log the latitude and longitude
        System.out.println("Latitude: " + location.getLat());
        System.out.println("Longitude: " + location.getLng());
    
        // Return the coordinates
        return new Coordinates(location.getLat(), location.getLng());
    }
    
    

    public DistanceTime getDistanceTime(String origin, String destination) throws Exception {
        String url = UriComponentsBuilder.fromHttpUrl("https://maps.googleapis.com/maps/api/distancematrix/json")
                .queryParam("origins", origin)
                .queryParam("destinations", destination)
                .queryParam("key", googleMapsApiKey)
                .toUriString();

        GoogleDistanceMatrixResponse response = restTemplate.getForObject(url, GoogleDistanceMatrixResponse.class);

        if (response != null && "OK".equals(response.getStatus())) {
            GoogleDistanceMatrixResponse.Element element = response.getRows().get(0).getElements().get(0);
            if ("OK".equals(element.getStatus())) {
                return new DistanceTime(element.getDistance().getText(), element.getDuration().getText());
            } else {
                throw new Exception("No routes found");
            }
        } else {
            throw new Exception("Unable to fetch distance and time");
        }
    }

    public List<String> getAutoCompleteSuggestions(String input) throws Exception {
        String url = UriComponentsBuilder.fromHttpUrl("https://maps.googleapis.com/maps/api/place/autocomplete/json")
                .queryParam("input", input)
                .queryParam("key", googleMapsApiKey)
                .toUriString();

        GoogleAutoCompleteResponse response = restTemplate.getForObject(url, GoogleAutoCompleteResponse.class);

        if (response != null && "OK".equals(response.getStatus())) {
            return response.getPredictions().stream().map(GoogleAutoCompleteResponse.Prediction::getDescription).toList();
        } else {
            throw new Exception("Unable to fetch suggestions");
        }
    }

    // public List<Driver> getCaptainsInTheRadius(double lat, double lng, double radius) {
    //     // Radius in km, assuming drivers are stored in a repository
    //     return driverRepository.findDriversWithinRadius(lat, lng, radius);
    // }
}
