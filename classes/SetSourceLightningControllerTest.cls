/* --------------------------------------------------------------------------------------------------
     Name:            SetSourceLightningControllerTest.cls 
     Description:     Test Class for Aura controller SetSourceLightningController
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class SetSourceLightningControllerTest {

	/**
	 * @description Test for setting up source using lightning component  . 
	 * 
	 **/
	@isTest private static void runPositiveTests() {

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

		User user = new User(LastName = 'Test',
		                     FirstName = 'User',
		                     Alias = 'utest',
		                     Email = 'santander@test.com',
		                     Username = 'santander@test.com',
		                     ProfileId = profileId.id,
		                     TimeZoneSidKey = 'GMT',
		                     LanguageLocaleKey = 'en_US',
		                     EmailEncodingKey = 'UTF-8',
		                     LocaleSidKey = 'en_US'
		);

		System.RunAs(user) {

			Account acct = PrepareTestData.getDefaultAccount();
			Database.insert(acct);

			Opportunity oppty = new Opportunity(Name = 'testLendingOpportunity', AccountId = acct.Id, StageName = 'New Opportunity', CloseDate = System.today());
			Database.insert(oppty);

			List<Account> accountList = new List<Account> { acct };
			String accountToUpsertString = JSON.serialize(accountList);

			List<Opportunity> opportunityList = new List<Opportunity> { oppty };
			String opptyToUpsertString = JSON.serialize(opportunityList);

			Test.startTest();
			SetSourceLightningController.setupAccountSource(accountToUpsertString);
			List<Account> accList = [SELECT Id, Name FROM Account];
			SetSourceLightningController.setupOpportunitySource(opptyToUpsertString);
			List<Opportunity> opptyList = [SELECT Id, Name FROM Opportunity];
			Test.stopTest();

			system.assertEquals(accountList.size(), accList.size());
			system.assertEquals(opportunityList.size(), opptyList.size());
		}
	}
    
    /**
	 * @description Test for getting record type  using lightning component  . 
	 * 
	 **/
    @isTest private static void testGetAccountRecordTypeMethod() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = PrepareTestData.getDefaultAccount();
        acct.RecordTypeId = accRecordTypeId;
        Database.insert(acct);
        String recordTypeName = null;
        Test.startTest();
        recordTypeName =SetSourceLightningController.getAccountRecordType(acct.Id);
        Test.stopTest();       
        System.assertEquals('Customer', recordTypeName);
    }
}