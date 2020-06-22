@IsTest
public class DataFactory  {


     private static  ID AcctBusinessRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
     private static  ID ContactBusinessRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId();
     private static  ID CaseClaimRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
     private static  ID CaseInvolvedPartyRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Involved Party').getRecordTypeId();
     private static String[] ClaimLineItemTypes = new String[]{'ACV', 'Administration Fee', 'Diminished Value',
                                                'Drug Fee', 'Independent/DV Appraisal Fee','Loss of Use','Misc Fee','Physical Damage',
                                                'Repair Related DV','Salvage','Sanitation Fee','Storage Fee','Sales Tax','Tax Title & License',
                                                'Tow Fee','Transport Fee','Write Off','Client Collected Deductible'};
    
    public static List<Lead> makeLeads(Integer numRows, Boolean doInsert) {
        List<Lead> retVal = new List<Lead> ();
        for (Integer i = 0; i < numRows; i++) {
            Lead objLead = new Lead();
            objLead.LeadSource = 'Website';
            objLead.Status = 'New';
            objLead.Company = 'Test';
            objLead.PostalCode = '12345';
            objLead.LastName = 'TestLead '+i;
            objLead.Email = 'test'+i+'@test.com';
            objLead.Business_Unit__c = 'Justrite';
            objLead.Customer_Type__c = 'Distributor';
            objLead.Inquiry_Type__c = 'Pricing';
            objLead.Industry = 'Automotive';
            retVal.add(objLead);
        }
		if (doInsert) {
            insert retVal; 
        }
        return retVal;
    }
	
    public static List<Account> makeAccounts(Integer numRows, Boolean doInsert) {
        List<Account> retVal = new List<Account>(); 
        for (Integer i = 0; i < numRows; i++) {
            Account acct = new Account();
            acct.Name = 'Account ' + i;
            acct.RecordTypeId = AcctBusinessRT;
            retVal.add(acct);
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;
    }
    
    public static List<Contact> makeContacts(Integer numRows, Id AccountId, Boolean doInsert) {
        List<Contact> retVal = new List<Contact>(); 
        for (Integer i = 0; i < numRows; i++) {
            Contact newContact = new Contact();
            newContact.FirstName = 'Test';
            newContact.LastName = 'Contact';
            newContact.RecordTypeId = ContactBusinessRT;
            newContact.AccountId = AccountId;
            retVal.add(newContact);
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;
    }
    public static List<Account_Statements__c> makeAccountStatements( Integer numRows, ID AccountID, Boolean doInsert) {
        List<Account_Statements__c> retVal = new List<Account_Statements__c> () ;
        for (Integer i = 0; i < numRows; i++) {
            Account_Statements__c acctStatement = new Account_Statements__c();
            acctStatement.Account__c = AccountID; 
            retVal.add(acctStatement);
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;  
    }

    public static List<Case> makeCases(Integer numRows, ID AccountID, ID MasterClaimId, Id ContactId,  Boolean involvedParty, Boolean doInsert) {
        List<Case> retVal = new List<Case>();
        for (Integer i = 0; i < numRows; i++) {
            Case newCase = new Case();
            newCase.RecordTypeId = involvedParty ? caseInvolvedPartyRT : caseClaimRT;
            if (involvedParty) 
                newCase.Master_Claim_Record__c = MasterClaimId; 
            newCase.Industry_Segment__c='Rental';
            newCase.Type='Full Service';
            newCase.AccountID = AccountID;
            newCase.ContactId = ContactId; 
            newCase.Sub_Office__c=AccountID;
            newCase.Loss_Type__c = 'Total Loss'; 
            newCase.Insured__c = 'Insured'; 
            retVal.add(newCase); 
        }
        
        if (doInsert) {
            insert retVal; 
        }
        return retVal;  

    }

    
    
    public static List<Claim_Line_Item__c> makeClaimLineItems(Integer numRows,  Id CaseId, Double Amount,   boolean doInsert) {
        List<Claim_Line_Item__c> retVal = new List<Claim_Line_Item__c>(); 
        for (Integer i = 0; i < numRows; i++) {
            Claim_Line_Item__c newCLI = new Claim_Line_Item__c();
            newCLI.Case__c = CaseId;
            newCLI.Amount__c = Amount;
            newCLI.Type__c = ClaimLineItemTypes[i];
            retVal.add(newCLI);
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;  

    }


    public static List<Payment_Demand__c> makePaymentDemands (Integer numRows, ID AccountID,Id MasterClaimId, ID InvolvedPartyId,  Boolean doInsert) {
        List<Payment_Demand__c> retVal = new List<Payment_Demand__c>();
        for (Integer i = 0; i < numRows; i++) {
            Payment_Demand__c newPd = new Payment_Demand__c();
            newPd.Account__c = AccountID;
            newPd.Involved_Party_Claim__c = InvolvedPartyId;
            newPd.Master_Claim__c = MasterClaimId;
            retVal.add(newPD); 
    
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;      
    }

    
    public static List<Payment_Demand_Line_Item__c> makePaymentDemandLineItems( Integer numRows, ID pdID, Id ClaimLineItemId, Double Amount,  Boolean doInsert) {
        List<Payment_Demand_Line_Item__c> retVal = new List<Payment_Demand_Line_Item__c>();
        for (Integer i = 0; i < numRows; i++) { 
            Payment_Demand_Line_Item__c newPDLI = new Payment_Demand_Line_Item__c();    
            newPDLI.Amount__c  = Amount;
            newPDLI.Claim_Line_Item__c = ClaimLineItemId;
            newPDLI.Payment_Demand__c = pdID;

            retVal.add(newPDLI); 
    
        }
        if (doInsert) {
            insert retVal; 
        }
        return retVal;      
    }

    public static List<Accounts_Receivable__c> makeAccountReceivables (Integer numRows, ID AccountID, ID MasterClaimId, ID InvolvedClaimId, 
                                                                        Id PaymentDemandId, String paymentReceivedBy, Boolean doInsert) {
        List<Accounts_Receivable__c> retVal = new List<Accounts_Receivable__c>();
        for (Integer i = 0; i < numRows; i++) {
            Accounts_Receivable__c newAR = new Accounts_Receivable__c();
            newAR.Account__c = AccountID; 
            newAR.Payment_Demand__c = PaymentDemandId;
            //newAR.Status__c = 'Accounting Approved';
            //  newAR.Status__c ='New';
            newAR.Status__c='Locked';
            newAR.Claim__c = MasterClaimId;
            newAR.Involved_Party__c = InvolvedClaimId;
            newAR.Total_Amount__c = 100; 
            newAR.Payment_Received_By__c = paymentReceivedBy;
          
            retVal.add(newAR); 
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;      
    }

    public static List<Accounts_Payable__c> makeAccountPayables(Integer numRows, ID AccountID, ID MasterClaimId, ID InvolvedClaimId, 
                                                                        Id PaymentDemandId, Id arID, Boolean doInsert) {
        List<Accounts_Payable__c> retVal = new List<Accounts_Payable__c>();
        for (Integer i = 0; i < numRows; i++) {
            Accounts_Payable__c newAp = new Accounts_Payable__c();
            newAp.Account__c= AccountID;
            newAp.Claim__c = MasterClaimId;
            newAp.Involved_Party__c = InvolvedClaimId;
            newAp.Payment_Demand__c = PaymentDemandId;
            newAp.Accounts_Receivable__c = arID;
            newAp.Amount__c=5;
            
            retVal.add(newAp);
    
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;      
    }

    public static List<Transactions__c> makeTransactions(Integer numRows,  ID ArId, ID ApId, ID CliId, ID pdliId,  Double Amount, String Type, Boolean acmFee, Boolean doInsert) {
        List<Transactions__c> retVal = new List<Transactions__c>();
        for (Integer i = 0; i < numRows; i++) {
            Transactions__c newTran = new Transactions__c();
            newTran.Account_Receivable__c = ArId;
            newTran.Accounts_Payable__c = ApId;
            newTran.Amount__c = Amount;
            newTran.Type__c = Type;
            newTran.ACM_Fee__c = acmFee;
            newTran.Claim_Line_Item__c = CliId;
            newTran.Payment_Demand_Line_Item__c = pdliId;
            
            retVal.add(newTran);
    
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;  
    }
    
    public static List<Claim_Requirement_Template__c> makeClaimRequirementTemplate(Integer numRows, Boolean doInsert) {
        List<Claim_Requirement_Template__c > retVal = new List<Claim_Requirement_Template__c >(); 
        for (Integer i = 0; i < numRows; i++) {
            Claim_Requirement_Template__c  newCQ = new Claim_Requirement_Template__c ();
            newCQ.Name = 'Test '+i;
            newCQ.Status__c = 'Completed';
            newCQ.Fulfilled_By__c = Math.mod(i,2)==0 ? 'Client' : 'ACM';
            retVal.add(newCQ);
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;
    }
    
    public static List<Claim_Requirement__c> makeClaimRequirements(Integer numRows, Id ClaimId, Boolean doInsert) {
        List<Claim_Requirement__c> retVal = new List<Claim_Requirement__c>(); 
        for (Integer i = 0; i < numRows; i++) {
            Claim_Requirement__c newCQ = new Claim_Requirement__c();
            newCQ.Name = 'Test '+i;
            newCQ.Status__c = 'Completed';
            newCQ.Requirement_Type__c = 'Document';
            newCQ.Fulfilled_By__c = 'Client';
            newCQ.Number_of_Files__c = 1;
            newCQ.Claim__c = ClaimId;
            newCQ.Required__c = true;
            retVal.add(newCQ);
        }

        if (doInsert) {
            insert retVal; 
        }
        return retVal;
    }
    
    public static List<ContentVersion> makeContentVersion(Integer numRows, Id parentId, Boolean doInsert) {
        List<ContentVersion> retVal = new list<ContentVersion>();
        Blob dataBlob = Blob.valueOf('Unit Test Attachment Body');
        for (Integer i = 0; i < numRows; i++) {
            ContentVersion cv = new ContentVersion();
            cv.FirstPublishLocationId = parentId;
            cv.Title = 'Test'+i;
            cv.PathOnClient = 'testPath'+i;           
            cv.VersionData = dataBlob;
            retVal.add(cv);
        }
        if (doInsert) {
            insert retVal; 
        }
        return retVal;
    }
}
