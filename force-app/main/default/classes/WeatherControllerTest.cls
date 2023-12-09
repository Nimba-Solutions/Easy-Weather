@isTest
public class WeatherControllerTest {

    @isTest
    static void testGetWeatherObservationsByLocation() {
        // Test input data
        String location = 'Phoenix';
        String responseBody = '{"temperature": 25.5, "humidity": 60.0}';

        // Mock the WeatherServices class to return a response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'application/json', responseBody));

        // Call the method to get weather observations by location
        String result = WeatherController.getWeatherObservations(location, null, null);


    }

    @isTest
    static void testGetWeatherObservationsByCoordinates() {
        // Test input data
        Double latitude = 40.7128;
        Double longitude = -74.0060;
        String responseBody = '{"temperature": 25.5, "humidity": 60.0}';

        // Mock the WeatherServices class to return a response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'application/json', responseBody));

        // Call the method to get weather observations by coordinates
        String result = WeatherController.getWeatherObservations(null, latitude, longitude);

        // Assert that the result is not null and matches the expected response body
        System.assertNotEquals(null, result);
        System.assertEquals(responseBody, result);
    }

    @isTest
    static void testGetWeatherObservationsInvalidLocation() {
        // Test input data with an invalid location
        String location = 'InvalidCity';

        // Mock the WeatherServices class to return null for GeoLocation
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'application/json', 'Invalid Response'));

        // Call the method to get weather observations with an invalid location
        String result = WeatherController.getWeatherObservations(location, null, null);

        // Assert that the result is null
        System.assertEquals(null, result);
    }

    @isTest
    static void testGetWeatherObservationsNoData() {
        // Test input data with no location or coordinates provided
        String location = null;
        Double latitude = null;
        Double longitude = null;

        // Call the method to get weather observations with no data
        String result = WeatherController.getWeatherObservations(location, latitude, longitude);

        // Assert that the result is null
        System.assertEquals(null, result);
    }
}