/*****************************************************************************
@ClassName  		: CommonBatchJob
@Purpose   			: Making batchable of all common basic script we run from annonymous window.
@TestClass			: CommonBatchJobTest
@Author				  : Arshad
@CreatedDate		: Sep 03, 2020
@LastModifiedDate	: Sep 04, 2020
@LastModifiedBy		: Arshad
******************************************************************************/
global class CommonBatchJob implements Database.Batchable<sObject> {
    global String qry;
    global String jobType; //Options: 'Validate', 'UpdateRecords', 'UpdateRecordsWithWhere', 'UpdateRecordsFromParent' , 'DeleteAllRecords', 'DeleteRecordsWithWhere'
    Map<String, Object> mapFieldValueToUpdate;
    Map<String, String> mapFldTargetFldSource;
    global CommonBatchJob(String jobType, String sObjApiName, Map<String, Object> mapFieldValues) {
        qry = 'SELECT Id FROM '+sObjApiName;
        mapFieldValueToUpdate = mapFieldValues;
        this.jobType = jobType; //UpdateRecords
    }
    global CommonBatchJob(String jobType, String sObjApiName, Map<String, Object> mapFieldValues, String strWhere) {
        qry = 'SELECT Id FROM '+sObjApiName+ ' WHERE '+strWhere;
        mapFieldValueToUpdate = mapFieldValues;
        this.jobType = jobType; //UpdateRecordsWithWhere
    }
    /* Example: UpdateRecordsFromParent
     * Map<String, String> mapTargetFldSourceFld = new Map<String, String>();
     * mapTargetFldSourceFld.put('FirstName', 'LastName');
     * mapTargetFldSourceFld.put('LastName', 'Account.Name');
     * Database.executeBatch(new CommonBatchJob('UpdateRecordsFromParent', 'Contact', mapTargetFldSourceFld, 'Id=\'00303000002BSxjAAG\'',  'FirstName, LastName, Account.Name'));
     * */
    global CommonBatchJob(String jobType, String sObjApiName, Map<String, String> mapTargetFldSourceFld, String strWhere, String strFieldsToSelect) {
        qry = 'SELECT '+strFieldsToSelect+' FROM '+sObjApiName+ ' WHERE '+strWhere; 
        this.mapFldTargetFldSource = mapTargetFldSourceFld;
        this.jobType = jobType; //UpdateRecordsFromParent
    }
    /* Example: DeleteRecordsWithWhere
     * Database.executeBatch(new CommonBatchJob('DeleteRecordsWithWhere', 'Contact', 'Id=\''+cons[0].Id+'\''));
     * */
    global CommonBatchJob(String jobType, String sObjApiName, String strWhere) {
        qry = 'SELECT Id FROM '+sObjApiName+ ' WHERE '+strWhere;
        this.jobType = jobType; //UpdateRecordsWithWhere
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(qry);
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(this.jobType=='Validate') {
            System.debug('Records size: '+scope.size());
            for(sObject so : scope) {
                System.debug(so);
            }
        } else if(this.jobType=='UpdateRecords' || this.jobType=='UpdateRecordsWithWhere') {
            for(sObject so : scope) {
                for(String field : mapFieldValueToUpdate.keySet()) {
                    so.put(field, mapFieldValueToUpdate.get(field));
                }
            }
            update scope;
        } else if(this.jobType=='UpdateRecordsFromParent') {
            for(sObject so : scope) {
                for(String fldTarget : mapFldTargetFldSource.keySet()) {
                    String fldSource = mapFldTargetFldSource.get(fldTarget);
                    if(fldSource.contains('.')) {
                        List<String> tok = fldSource.split('[.]');
                        so.put(fldTarget, so.getSobject(tok[0]).get(tok[1]));
                    } else {
                        so.put(fldTarget, so.get(mapFldTargetFldSource.get(fldTarget)));
                    }
                }
            }
            System.debug(scope);
            update scope;
        } else if(this.jobType=='DeleteRecordsWithWhere') {
            System.debug('Deleting '+scope);
            delete scope;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}
