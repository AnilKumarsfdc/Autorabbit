/* --------------------------------------------------------------------------------------------------
     Name:            LookupLightningControllerTest.cls 
     Description:     Test functionality of Lookup Lightning controller to check if returned results
     				  of search for lightning component, match the expectations
    ------------------------------------------------------------------------------------------------ */
@IsTest
private class LookupLightningControllerTest {
	private static final String TEST_CRITERIA = 'TEST CRITERIA';
	
	/** 
	 * @description : Check if execution and retrieving most recent items works as expected
	 **/	
	private static testMethod void testMostRecentItemsSearchResult() {
		Integer numberOfAccountsToInsert = LookupLightningController.DISPLAY_LOOKUP_LIMIT * 2;
		Account testAccount = PrepareTestData.getDefaultAccount();
		Database.insert(testAccount);
		
		List<Contact> testContacts = new List<Contact>();		
		for (Integer index = 0; index < numberOfAccountsToInsert; index++) {
			testContacts.add(PrepareTestData.getTestContact(testAccount.Id));
		}
		Database.insert(testContacts);
		
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			List<sObject> resultItems = LookupLightningController.fetchLookupValues('Contact', null);
			Test.stopTest();
			//Check that result contains maximum allowed number of records
			System.assertEquals(LookupLightningController.DISPLAY_LOOKUP_LIMIT, resultItems.size());
		}
	}  
	
	/** 
	 * @description : Check if matching criteria function works fine
	 **/	
	private static testMethod void testMatchingCriteriaSearchResult() {
		Integer numberOfDummyAccountsToInsert = LookupLightningController.DISPLAY_LOOKUP_LIMIT;
		Integer numberOfMatchingAccountsToInsert = PrepareTestData.randomInt(
			1, 	LookupLightningController.DISPLAY_LOOKUP_LIMIT - 1
		);
		
		List<Account> testAccounts = new List<Account>();		
		for (Integer index = 0; index < numberOfDummyAccountsToInsert; index++) {
			testAccounts.add(PrepareTestData.getDefaultAccount());
		}
		Database.insert(testAccounts);
		
		Account testAccount;
		Integer intLimit = Limits.getLimitCpuTime();
		testAccounts = new List<Account>();
		for (Integer index = 0; index < numberOfMatchingAccountsToInsert; index++) {
			testAccount = PrepareTestData.getDefaultAccount();
			testAccount.Name = TEST_CRITERIA + ' ' + PrepareTestData.randomInt(intLimit);
			testAccounts.add(testAccount);
		}		
		Database.insert(testAccounts);
		
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Set<Id> searchResults = (new Map<Id, sObject>(testAccounts)).keySet(); 
			Test.setFixedSearchResults(new List<Id>(searchResults));
			Test.startTest();
			List<sObject> resultItems = LookupLightningController.fetchLookupValues('Account', TEST_CRITERIA);
			Test.stopTest();
			//Check that result contains maximum allowed number of records
			System.assertEquals(numberOfMatchingAccountsToInsert, resultItems.size());
		}
	}  
}