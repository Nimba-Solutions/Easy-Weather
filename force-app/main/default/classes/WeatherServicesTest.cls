@isTest
public class WeatherServicesTest {

    @isTest
    static void testResolveCityCoordinates() {
        // Test input data
        String cityName = 'Phoenix';
        String responseBody = '<geonames><address><street>Phoenix Memorial Cemetery</street><houseNumber/><locality>Phoenix</locality><postalcode/><lng>-112.07518</lng><lat>33.67015</lat><adminCode1>AZ</adminCode1><adminName1>Arizona</adminName1><adminCode2>013</adminCode2><adminName2>Maricopa</adminName2><adminCode3/><adminCode4/><countryCode>US</countryCode></address></geonames>';

        // Mock the HTTP callout with a custom response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'application/xml', responseBody));

        // Call the method to resolve city coordinates
        WeatherServices.GeoLocation location = WeatherServices.resolveCityCoordinates(cityName);

        // Assert that the location is not null
        System.assertNotEquals(null, location);
        System.assertEquals(33.67015, location.latitude);
        System.assertEquals(-112.07518, location.longitude);
    }

    @isTest
    static void testGetWeatherObservations() {
        // Test input data
        Double latitude = 40.7128;
        Double longitude = -74.0060;
        String responseBody = '{"temperature": 25.5, "humidity": 60.0}';

        // Mock the HTTP callout with a custom response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'application/json', responseBody));

        // Call the method to get weather observations
        HttpResponse response = WeatherServices.getWeatherObservations(latitude, longitude);

        // Assert that the response status code is 200 (OK)
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void testDeserializeResponse() {
        // Test JSON response data
        String jsonResponse = '{"temperature": 25.5, "humidity": 60.0}';

        // Call the method to deserialize the JSON response
        WeatherObservationsWrapper observationsWrapper = WeatherServices.deserializeResponse(jsonResponse);

        // Assert that the deserialized object is not null
        System.assertNotEquals(null, observationsWrapper);
    }
}