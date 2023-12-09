public class WeatherController {

    @AuraEnabled(cacheable=true)
    public static String getWeatherObservations(String location, Double latitude, Double longitude) {
        HttpResponse res;

        if (String.isNotBlank(location)) {
            // If location (city name) is provided, resolve to latitude and longitude
            WeatherServices.GeoLocation geoLocation = WeatherServices.resolveCityCoordinates(location);
            if (geoLocation == null) {
                System.debug('Error: Unable to resolve city coordinates.');
                return null;
            }
            res = WeatherServices.getWeatherObservations(geoLocation.latitude, geoLocation.longitude);
        } else if (latitude != null && longitude != null) {
            // If latitude and longitude are provided, use them directly
            res = WeatherServices.getWeatherObservations(latitude, longitude);
        } else {
            // If neither city name nor coordinates are provided, log an error
            System.debug('Error: Insufficient data provided for weather observation callout.');
            return null;
        }

        // Process the response
        if (res.getStatusCode() == 200) {
            // Deserialize and return the weather observations
            system.debug('RESPONSE: '+ res.getBody());
            return res.getBody();
        } else {
            // Handle error scenarios
            System.debug('Error in callout: ' + res.getStatusCode() + ' ' + res.getStatus());
            return null;
        }
    }
}