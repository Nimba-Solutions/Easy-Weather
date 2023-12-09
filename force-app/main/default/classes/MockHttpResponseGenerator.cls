public class MockHttpResponseGenerator implements HttpCalloutMock {
    private String responseBody;
    private Integer statusCode;
    private String contentType;

    public MockHttpResponseGenerator(Integer statusCode, String contentType, String responseBody) {
        this.statusCode = statusCode;
        this.contentType = contentType;
        this.responseBody = responseBody;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', contentType);
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }
}