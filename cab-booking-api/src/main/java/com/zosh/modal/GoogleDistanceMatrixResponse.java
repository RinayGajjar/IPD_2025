package com.zosh.modal;

// GoogleDistanceMatrixResponse.java
import java.util.List;

public class GoogleDistanceMatrixResponse {
    private String status;
    private List<Row> rows;

    public String getStatus() {
        return status;
    }

    public List<Row> getRows() {
        return rows;
    }

    public static class Row {
        private List<Element> elements;

        public List<Element> getElements() {
            return elements;
        }
    }

    public static class Element {
        private Distance distance;
        private Duration duration;
        private String status;

        public Distance getDistance() {
            return distance;
        }

        public Duration getDuration() {
            return duration;
        }

        public String getStatus() {
            return status;
        }
    }

    public static class Distance {
        private String text;
        private int value;

        public String getText() {
            return text;
        }

        public int getValue() {
            return value;
        }
    }

    public static class Duration {
        private String text;
        private int value;

        public String getText() {
            return text;
        }

        public int getValue() {
            return value;
        }
    }
}

