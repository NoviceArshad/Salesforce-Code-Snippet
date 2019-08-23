@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('http://aflacservices.suth.com/service.asmx?WSDL', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        chs_LeadAPI_Sutherland chs_LSL = new chs_LeadAPI_Sutherland(); 
        String resStr = chs_LSL.getResponseSampleXML();
        res.setBody(resStr);
        res.setStatusCode(200);
        return res;
    }
}