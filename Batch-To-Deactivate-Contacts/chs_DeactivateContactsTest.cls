@isTest
public class chs_DeactivateContactsTest {
	@isTest static void check(){
     
    List<Contact> listContactToUpdate = new List<Contact>();   
    Contact con=new Contact();
    con.LastName = 'Test';
    con.Inactive__c = true;
    listContactToUpdate.add(con);
    
    insert listContactToUpdate;
    
  	Test.startTest();
    chs_DeactivateContacts x = new chs_DeactivateContacts();
    
    Database.QueryLocator ql = x.start(null);
	x.execute(null,listContactToUpdate);
	x.Finish(null);    
        
    Test.stopTest();
    }
}