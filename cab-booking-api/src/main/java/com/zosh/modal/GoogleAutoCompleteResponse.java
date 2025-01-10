package com.zosh.modal;

// GoogleAutocompleteResponse.java
import java.util.List;

public class GoogleAutoCompleteResponse {
    private String status;
    private List<Prediction> predictions;

    public String getStatus() {
        return status;
    }

    public List<Prediction> getPredictions() {
        return predictions;
    }

    public static class Prediction {
        private String description;

        public String getDescription() {
            return description;
        }
    }
}
