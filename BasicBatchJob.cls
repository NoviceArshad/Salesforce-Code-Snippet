global class BasicBatchJob implements Database.Batchable<sObject> {
    global String qry;
    Map<String, Object> mapFieldValueToUpdate;
    global BasicBatchJob(String sObjApiName, Map<String, Object> mapFieldValues) {
        qry = 'SELECT Id FROM '+sObjApiName;
        mapFieldValueToUpdate = mapFieldValues;
    }
    global BasicBatchJob(String sObjApiName, Map<String, Object> mapFieldValues, String strWhere) {
        qry = 'SELECT Id FROM '+sObjApiName+ ' WHERE '+strWhere;
        mapFieldValueToUpdate = mapFieldValues;
    }
    global BasicBatchJob(String sObjApiName, Map<String, Object> mapFieldValues, String strWhere, String strFieldsToSelect) {
        qry = 'SELECT '+strFieldsToSelect+' FROM '+sObjApiName+ ' WHERE '+strWhere; 
        mapFieldValueToUpdate = mapFieldValues;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(qry);
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(sObject so : scope) {
            for(String field : mapFieldValueToUpdate.keySet()) {
                so.put(field, mapFieldValueToUpdate.get(field));
            }
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}
