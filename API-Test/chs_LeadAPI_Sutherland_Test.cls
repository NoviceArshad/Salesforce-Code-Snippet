@isTest 
global class chs_LeadAPI_Sutherland_Test { 
    @TestSetup
    global static void testSetup(){
    }
    
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        chs_LeadAPI_Sutherland chs_LSL = new chs_LeadAPI_Sutherland(); 
        HttpResponse res = chs_LSL.callScheduleCallback3();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/soap+xml; charset=utf-8');
        String actualValue = res.getBody();
        String expectedValue = chs_LSL.getResponseSampleXML();
    }
}