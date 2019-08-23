/** 
	* @Purpose: This class is a Queueable with a Invocable method to integrate with sharepoint
 	* - Queueable has been implemented because the Invocable method will be called from a Process Builder (or trigger)
	* - From trigger or process builder, an error shows up as 'You have uncommitted work pending'
    * @Author: Cloud Haven Solutions
    * @CreatedDate: 08/21/2019
    * @Test Class:
    * @LastModifiedDate: 08/21/2019
    * @LastModifiedBy: Arshad
*/
public class chs_SharepointSetMetadata implements Queueable, Database.AllowsCallouts {
    String spFolderId;
    Map<String,String> mapFieldValues;
    public chs_SharepointSetMetadata(String spFolderId, Map<String,String> mapFieldValues){
        this.spFolderId = spFolderId;
        this.mapFieldValues = mapFieldValues;
    }
    
    @InvocableMethod(label='UpdateSharepointMetadata')
    public static void setSharepointSetMetadata(List<Id> listOppId) {
        for(Opportunity opp : [SELECT SharePointFolderId__c FROM Opportunity WHERE Id IN :listOppId]){
            Map<String,String> mapFieldValues = new Map<String,String>();
            mapFieldValues = getMetadataMap(opp.Id);
            System.enqueueJob(new chs_SharepointSetMetadata(opp.SharePointFolderId__c, mapFieldValues));
        }
    }
    
    public void execute(QueueableContext context) {
        SharePointOnlineUtility.setSharePointFolderMetadata(this.spFolderId, this.mapFieldValues );
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