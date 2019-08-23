@isTest 
global class chs_PostLeadsB2C_Test { 
    @TestSetup
    global static void testSetup(){
    }
    
    @isTest 
    global static void testsaveLeadsB2C(){ 
        Map<String, String> testMap =  new Map<String, String>();
        testMap.put('test1','test1');
        List<Map<String, String>> Offerings = new List<Map<String, String>>();
        Offerings.add(testMap);
  
        chs_PostLeadsB2C.saveLeadsB2C('prefix','FirstName','LastName','test@test.com','222-222-2222','NY','NY','202020','BillingType','12334',Offerings,'ContactMeType',
                                      'ContactMeDateTime','web', 'website', 'campaign2', 'term2', 'no content', 'test2', 'test1');
    }
}