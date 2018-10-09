/*
######################################################################################################
# Created by............: Cloud Haven Solutions
# Created Date..........: 3rd October 2018
# Description...........: Class for Synchronizing Account and Contacts with Attachment CSV file
######################################################################################################
*/
global class chs_SynchronizeAccountContact implements Messaging.InboundEmailHandler
{
    public void chs_SynchronizeAccountContact() {}
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('Received Email');
        if (email.textAttachments  != null && email.textAttachments.size() > 0) {
            System.debug('Received Attachment');
            this.syncContactAccount(this.parseCSV(email.textAttachments[0].body, True));
        } else if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            this.syncContactAccount(this.parseCSV(email.binaryAttachments[0].body.toString(), True));
        }
		return result;
    }
    
    global List<List<String>> parseCSV(String contents, Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
    
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');	
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;		
    }
    
    global void syncContactAccount(List<List<String>> allFields) {
        // Get all account within Salesforce
        Map<String, Account> mapSFAccounts = new Map<String, Account>();
        for(Account a: [SELECT Id, Name, Tenant_Id__c FROM Account WHERE Tenant_Id__c != NULL]) {
            mapSFAccounts.put(a.Tenant_Id__c, a);
        }
        Set<String> setSFTenentId = new Set<String>();
        setSFTenentId.addAll(mapSFAccounts.keySet());
		
        Map<String, Account> mapAccToCreate = new Map<String, Account>();
        for(List<String> line: allFields) {
            String tenantId = line[0], tenantName=line[1];
            if(!setSFTenentId.contains(tenantId)) { // If account not exists
                Account a = new Account(Name=tenantName, Tenant_Id__c=tenantId);
                mapAccToCreate.put(tenantId, a);
                mapSFAccounts.put(tenantId, a);
            }
        }
        if(!mapAccToCreate.isEmpty()) {
            Database.insert(mapAccToCreate.values());
        }
        
        // Get all contacts within Salesforce        
        Map<String, Contact> mapSFContacts = new Map<String, Contact>();
        for(Contact c: [SELECT Id, Name, User_Id__c, Account.Tenant_Id__c FROM Contact WHERE User_Id__c != NULL]) {
            mapSFContacts.put(c.Account.Tenant_Id__c.trim()+'_'+c.User_Id__c.trim(), c);
        }
        System.debug(mapSFContacts);
        Set<String> setSFUserId = new Set<String>();
        setSFUserId.addAll(mapSFContacts.keySet());
		System.debug(setSFUserId);
        Set<String> setImportUserId = new Set<String>();
		
        List<Contact> listContactToCreate = new List<Contact>();
        List<Contact> listContactToUpdate = new List<Contact>();
        for(List<String> line: allFields) {
            String tenantId=line[0], tenantName=line[1], userId=line[2], userName=line[3], userEmail=line[4];
            List<String> listNameParts = userName.trim().split(' ');
            String fName = (listNameParts.size() > 1) ? listNameParts[0] : '';
            String lName = (listNameParts.size() == 1) ? listNameParts[0] : (listNameParts.size() == 2 ? listNameParts[1] : '');
            String strUser = tenantId.trim() + '_' + userId.trim();
            setImportUserId.add(strUser);
            if(setSFUserId.contains(strUser) == False) { // If contact not exists
                Id idAcc = Null;
                if(mapSFAccounts.containsKey(tenantId)) idAcc = mapSFAccounts.get(tenantId).Id;
                Contact c = new Contact(FirstName=fName, LastName=lName, User_Id__c=userId, Email=userEmail, AccountId=idAcc);
                listContactToCreate.add(c);
            } else {
                Contact c = mapSFContacts.get(strUser);
				c.FirstName = fName;
                c.LastName = lName;
                c.User_Id__c = userId;
                c.Email = userEmail;
                listContactToUpdate.add(c);
            }
        }
        //System.debug('listContactToCreate: '+listContactToCreate.size());
        //System.debug('listContactToUpdate: '+listContactToUpdate.size());
        if(!listContactToCreate.isEmpty()) Database.insert(listContactToCreate, false);
        if(!listContactToUpdate.isEmpty()) Database.update(listContactToUpdate, false);
        setSFUserId.removeAll(setImportUserId);
        if(!setSFUserId.isEmpty()){
            List<Contact> listContactToDeactivate = new List<Contact>();
            for(String uid: setSFUserId) {
                mapSFContacts.get(uid).Inactive__c = true;
                listContactToDeactivate.add(mapSFContacts.get(uid));
            }
            if(!listContactToDeactivate.isEmpty()) {
                Database.update(listContactToDeactivate);
            }
        }
    }
}