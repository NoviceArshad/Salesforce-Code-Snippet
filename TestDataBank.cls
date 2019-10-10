@isTest
public class TestDataBank {
    public static Account createAccount(Boolean isInsert) {
        Account accObj = new Account();
        accObj.Name = 'Test Account';
        accObj.Lead_Source__c = 'Email';
        accObj.Lead_Status__c = 'CUSTOMER-Closed Won';
        accObj.Netsuite_Account_Number__c ='1234567';  
        accObj.MDR_Group_Number__c ='9090'; 
        accObj.BillingCity='Pune';
        //accList.add(accObj);
        if(isInsert) {
            insert accObj;
		}
        return accObj;
    }
 	
    public static Product2 createProduct(Boolean isInsert) {
        Product2 p = new Product2();
        p.Name = 'Test Prod';
        p.IsActive = True;
        if(isInsert) {
            insert p;
        }
        return p;
    }
    
    public static Order createOrder(Boolean isInsert) {
        Account act = createAccount(true);
        Order o = new Order();
        o.AccountId = act.Id;
        o.Pricebook2Id = Test.getStandardPricebookId();
        o.EffectiveDate = Date.today();
        o.Status = 'Draft';
        if(isInsert) {
            insert o;
        }
        return o;
    }
	
    public static OrderItem createOrderItem(Boolean isInsert) {
        //Product2 p = createProduct(true);
        PricebookEntry pbe = createPricebookEntry(True);
        Order o = createOrder(true);
        OrderItem oi = new OrderItem();
        oi.OrderId = o.Id;
        oi.Product2Id = pbe.Product2Id;
        oi.PricebookEntryId = pbe.Id;
        oi.UnitPrice = 100;
        oi.Quantity = 2;
        if(isInsert) {
            insert oi;
        }
        return oi;
    }
	
    public static PricebookEntry createPricebookEntry(Boolean isInsert) {
        Product2 p = createProduct(true);
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = p.Id,
            UnitPrice = 100,
            IsActive = true
        );
        if(isInsert) {
            insert testPbe;
        }
        return testPbe;
    }
	  
}