public class WeatherServices {

    private static final String WEATHER_URL = 'http://api.geonames.org/weatherJSON';
    private static final String GEOCODE_URL = 'http://api.geonames.org/geoCodeAddress';
    private static final String USERNAME = 'nimba';
    
    // Method to resolve city name to GeoLocation (latitude and longitude)
    public static GeoLocation resolveCityCoordinates(String cityName) {
        String requestUrl = GEOCODE_URL + '?q=' + EncodingUtil.urlEncode(cityName, 'UTF-8') + '&username=' + USERNAME;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestUrl);
        req.setMethod('GET');

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                // Parse the XML response to extract latitude and longitude
                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
                Dom.XmlNode root = doc.getRootElement();
                Dom.XmlNode address = root.getChildElement('address', null);
                Double latitude = Double.valueOf(address.getChildElement('lat', null).getText());
                Double longitude = Double.valueOf(address.getChildElement('lng', null).getText());

                return new GeoLocation(latitude, longitude);
            } else {
                System.debug('Error in geoCodeAddress callout: ' + res.getStatus());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception in geoCodeAddress callout: ' + e.getMessage());
            return null;
        }
    }
    
    // Method to make the callout and return the response
    public static HttpResponse getWeatherObservations(Double latitude, Double longitude) {
        // Calculate the bounds based on the provided latitude and longitude
        Double range = 10.0; // Define the range for calculating the bounds (e.g., 10 km)
        Double north = latitude + (range / 110.574); // Approximate conversion for latitude
        Double south = latitude - (range / 110.574);
        Double east = longitude + (range / (111.320 * Math.cos(latitude * Math.PI / 180)));
        Double west = longitude - (range / (111.320 * Math.cos(latitude * Math.PI / 180)));

        // Construct the request URL
        String requestUrl = WEATHER_URL + 
                            '?north=' + String.valueOf(north) +
                            '&south=' + String.valueOf(south) +
                            '&east=' + String.valueOf(east) +
                            '&west=' + String.valueOf(west) +
                            '&username=' + USERNAME;

        // Create a new Http request and set the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestUrl);
        req.setMethod('GET');

        // Create a new Http object to send the request
        Http http = new Http();
        HttpResponse res;

        try {
            // Send the request and receive the response
            res = http.send(req);
        } catch(System.CalloutException e) {
            // Handle the exception (e.g., log the error)
            System.debug('Callout error: '+ e.getMessage());
            res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Callout error');
        }

        return res;
    }
    
    // Method to deserialize the JSON response into WeatherObservationsWrapper
    /*public static WeatherObservationsWrapper deserializeResponse(String jsonResponse) {
        // Deserialize the JSON response
        WeatherObservationsWrapper observationsWrapper = 
            (WeatherObservationsWrapper) JSON.deserialize(jsonResponse, WeatherObservationsWrapper.class);
        return observationsWrapper;
    }*/
    
    // Inner class to represent geographical location
    public class GeoLocation {
        public Double latitude;
        public Double longitude;

        public GeoLocation(Double latitude, Double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }
}