public class DynamicApex {
    @AuraEnabled    
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        //  lstPickvals.add('None');//add default None
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }//loop ends here
        return lstPickvals; 
    }

    /**
    * @Purpose: The mapping between some keyword and SF field API name are exist in a Custom Metadata Type
    * This method grabs field names from the mdt and generate the query. 
    * Importantly, it can grab retrieved data from the parent's object (single level only)
    * @Return: A string map between the keywords and retrieved data
    */
    public static Map<String,String> getMetadataMap(Id idOpp) {
        Sharepoint_Metadata_Mapping__mdt [] threatMappings = [SELECT MasterLabel, QualifiedApiName, Opportunity_Field_Name__c, Sharepoint_Column_Name__c 
                                                              FROM Sharepoint_Metadata_Mapping__mdt];
        String fields = '';
        Map<String,String> mapFields = new Map<String,String>();
        for (Sharepoint_Metadata_Mapping__mdt threatMapping : threatMappings) {
            fields += threatMapping.Opportunity_Field_Name__c+',';
            mapFields.put(threatMapping.Sharepoint_Column_Name__c, threatMapping.Opportunity_Field_Name__c);
        }
        fields = fields.removeEnd(',');
        String qry = 'SELECT '+fields+' FROM Opportunity WHERE Id = :idOpp';
        Opportunity opp = Database.query(qry);
        
        Map<String,String> mapFieldValues = new Map<String,String>();
        for(String k : mapFields.keySet()) {
            String fname = mapFields.get(k);
            if(fname.contains('.')) {
                List<String> tok = fname.split('[.]');
                mapFieldValues.put(k, String.valueOf(opp.getSobject(tok[0]).get(tok[1])));
            } else {
                mapFieldValues.put(k, String.valueOf(opp.get(fname)));
            }
        }
        System.debug('metadatamap: '+mapFieldValues);
        return mapFieldValues;
    }
}