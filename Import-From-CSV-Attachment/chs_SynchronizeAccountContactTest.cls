@isTest()

public class chs_SynchronizeAccountContactTest {
    @isTest static void check1(){
      
      List<Contact> listContactToUpdate = new List<Contact>();
      
      Account accountReference = new Account(Name='Test',Tenant_Id__c='123456789');     
      insert accountReference; 
        
      Contact con = new Contact();
      con.LastName = 'Test';
      con.User_Id__c = '123456789';
      con.Inactive__c = false;
      con.AccountId = accountReference.Id;
      listContactToUpdate.add(con);
    
      insert listContactToUpdate;    
      
      // create a new email and envelope object
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
      // setup the data for the email
      email.subject = 'Test Email';
      email.fromAddress = 'sajjad@innovit.io';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('tenantId,tenantName,userId,userName,userEmail \r\n 35,"	chef","	1","	Allison Elmer","	aelmer@chef.io"');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
          
      // add an Text atatchment
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'tenantId,tenantName,userId,userName,userEmail \r\n 35,"	chef","	1","	Allison Elmer","	aelmer@chef.io"';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
      
      Test.startTest();  
              
      chs_SynchronizeAccountContact  testInbound=new chs_SynchronizeAccountContact ();
      testInbound.handleInboundEmail(email, env);
      Test.stopTest();

        
    }
}