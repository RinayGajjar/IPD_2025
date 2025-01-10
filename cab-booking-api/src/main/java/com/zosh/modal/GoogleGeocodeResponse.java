package com.zosh.modal;

import java.util.List;
import com.google.gson.Gson;

public class GoogleGeocodeResponse {
    private String status;
    private List<Result> results;

    public String getStatus() {
        return status;
    }

    public List<Result> getResults() {
        return results;
    }

    public static class Result {
        private Geometry geometry;
        private String formatted_address; // New field added to match JSON response

        public Geometry getGeometry() {
            return geometry;
        }

        public String getFormattedAddress() { // Getter for formatted_address
            return formatted_address;
        }
    }

    public static class Geometry {
        private Location location;

        public Location getLocation() {
            return location;
        }
    }

    public static class Location {
        private double lat;
        private double lng;

        public double getLat() {
            return lat;
        }

        public double getLng() {
            return lng;
        }
    }

    @Override
    public String toString() {
        return new Gson().toJson(this);
    }
}
