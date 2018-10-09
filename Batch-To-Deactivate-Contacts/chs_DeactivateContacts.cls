/*
######################################################################################################
# Created by............: Cloud Haven Solutions
# Created Date..........: 2nd October 2018
# Description...........: Class for Deactivating the inactive Contacts
######################################################################################################
*/
global class chs_DeactivateContacts implements Database.Batchable<SObject>, Schedulable {
    
    private String aquery=null;
    public chs_DeactivateContacts() //String query 
    {

    }
    
    global database.querylocator start(Database.BatchableContext bc)
    { 
        //Id idTest = 'a6ff20000000IVd';
        String DaysBack = '7'; //Label.chs_ContactInactiveDays;
        DateTime dt = System.Today() - integer.valueof(DaysBack);
        String Query = 'SELECT Id, Inactive__c FROM Contact WHERE Inactive__c=False AND LastModifiedDate  < '+ dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
       
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, Contact[] listContact)
    {
        List<Contact> listContactToUpdate = new List<Contact>();
        for(Contact con: listContact) {
            con.Inactive__c = true;
            listContactToUpdate.add(con);
        }
        System.debug(listContactToUpdate);
        if(listContactToUpdate.size() > 0) update listContactToUpdate;
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
    global void execute(SchedulableContext sc)
    {
        chs_DeactivateContacts job = new chs_DeactivateContacts();
        Database.executeBatch(job);
    }
}