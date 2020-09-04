/*****************************************************************************
@ClassName  		: CommonBatchJobTest
@Purpose   			: Test class for CommonBatchJob
@TestClass			: N/A
@Author				  : Arshad
@CreatedDate		: Sept 03, 2020
@LastModifiedDate	: Aug 04, 2020
@LastModifiedBy		: Arshad
******************************************************************************/
@isTest
public class CommonBatchJobTest {
	@isTest
    public static void testJob() {
        List<Account> accs = DataFactory.makeAccounts(1, true);
        List<Contact> cons = DataFactory.makeContacts(2, accs[0].Id, true);
        
        Map<String, String> mapTargetFldSourceFld = new Map<String, String>();
        mapTargetFldSourceFld.put('FirstName', 'LastName');
        mapTargetFldSourceFld.put('LastName', 'Account.Name');
        Database.executeBatch(new CommonBatchJob('UpdateRecords', 'Contact', mapTargetFldSourceFld));
        new CommonBatchJob('UpdateRecords', 'Contact', mapTargetFldSourceFld, 'Id=\''+cons[0].Id+'\'');
        Database.executeBatch(new CommonBatchJob('UpdateRecordsFromParent', 'Contact', mapTargetFldSourceFld, 'Id=\''+cons[0].Id+'\'',  'FirstName, LastName, Account.Name'));
        Database.executeBatch(new CommonBatchJob('DeleteRecordsWithWhere', 'Contact', 'Id=\''+cons[0].Id+'\''));
    }
}
