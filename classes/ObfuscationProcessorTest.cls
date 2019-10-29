/* --------------------------------------------------------------------------------------------------
Name:            ObfuscationProcessor.cls 
Description:     Class which executes tests Obscuration functionality both for Contact and BDP Contacts.
				 The obscuration process should be started based on defined trigger functionality. 
------------------------------------------------------------------------------------------------ */
@isTest
private class ObfuscationProcessorTest {
	private final static String DUMMY_CONFIDENTIAL_PROJECT_NAME = 'GDPR Test';
	
	/*
	* @describe Create Custom Settings which will be used to specify Dummy Account to reassign contacts after obscuration
	*/
	@testSetup static void prepareTestData(){
		Account dummyAccount = PrepareTestData.getDefaultAccount();
		dummyAccount.Name = DUMMY_CONFIDENTIAL_PROJECT_NAME;
		Database.insert(dummyAccount);
		
		Config_Settings__c defaultConfigSettings = new Config_Settings__c();
		defaultConfigSettings.Obfuscation_Dummy_Account_Name__c = DUMMY_CONFIDENTIAL_PROJECT_NAME;
		defaultConfigSettings.SetupOwnerId = UserInfo.getOrganizationId();
		Database.upsert(defaultConfigSettings);
	}
	
	/*
	* @describe Method class tests obscuration process for Salesforce Contact. Next criterias are tested:
	* 1) Original Record is Deleted
	* 2) Obscured clone is created
	* 3) Child Event is reassigned
	* 4) Related unobscured BDP Contacts are updated to unset Salesforce Contact Lookup 
	*/
	public static testMethod void testContactDirectObfuscation() {
		Account defaultAccount = PrepareTestData.getDefaultAccount();
		Database.insert(defaultAccount);
		
		Contact testContact = PrepareTestData.getTestContact(defaultAccount.Id);
		Database.insert(testContact);
		
		BDP_Contact__c relatedBdpContact1 = PrepareTestData.getTestBDPContact(testContact.Id),
					   relatedBdpContact2 = PrepareTestData.getTestBDPContact(testContact.Id);
					   
		Database.insert(new List<BDP_Contact__c>{relatedBdpContact1, relatedBdpContact2});
		
		Event newEvent = PrepareTestData.getDefaultEvent(defaultAccount.Id);
		newEvent.WhoId = testContact.Id;
		Database.insert(newEvent);
		
		Test.startTest();
		ObfuscationProcessor.isDebugMode = true;
		Database.update(new Contact(Id = testContact.Id, GDPR_Obscuration_Requested__c = true));
		Test.stopTest();
		
		Integer remainingCount = [SELECT COUNT() FROM Contact WHERE Id = :testContact.Id];
		System.assertEquals(0, remainingCount);
		
		Contact contactResult = [SELECT Id, FirstName, Account.Name FROM Contact WHERE GDPR_Salesforce_Old_Id__c = :testContact.Id LIMIT 1];
		System.assert(contactResult.FirstName.contains('GDPR'));
		System.assertEquals(DUMMY_CONFIDENTIAL_PROJECT_NAME, contactResult.Account.Name);
		
		BDP_Contact__c resultBDPContact = [SELECT Id, Salesforce_Contact__C FROM BDP_Contact__c 
										  WHERE Id = :relatedBdpContact1.Id LIMIT 1];
		System.assertEquals(null, resultBDPContact.Salesforce_Contact__C);
		
		Event resultEvent = [SELECT Id, WhoId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
		System.assertEquals(contactResult.Id, resultEvent.WhoId);
	}    
	
	/*
	* @describe Method class tests obscuration process for BDP Contact, when both BDP Contacts related to Salesforce Contact 
	* should be obscured. Next criterias are tested:
	* 1) Original Record is Deleted
	* 2) Obscured clone is created
	* 3) Related Salesforce Contact Obscuration is requested
	*/
	public static testMethod void testBDPContactObfuscationForAllBothRecords() {
		Account defaultAccount = PrepareTestData.getDefaultAccount();
		Database.insert(defaultAccount);
		
		Contact testContact = PrepareTestData.getTestContact(defaultAccount.Id);
		Database.insert(testContact);
		
		BDP_Contact__c relatedBdpContact1 = PrepareTestData.getTestBDPContact(testContact.Id),
					   relatedBdpContact2 = PrepareTestData.getTestBDPContact(testContact.Id);
					   
		Database.insert(new List<BDP_Contact__c>{relatedBdpContact1, relatedBdpContact2});
		Set<Id> bdpContactIdSet = new Set<Id>{relatedBdpContact1.Id, relatedBdpContact2.Id};
		
		Test.startTest();
		ObfuscationProcessor.isDebugMode = true;
		Database.update(new List<BDP_Contact__c>{
			new BDP_Contact__c(Id = relatedBdpContact1.Id, GDPR_Obscuration_Requested__c = true, 
							   Salesforce_Contact__c = testContact.Id),
			new BDP_Contact__c(Id = relatedBdpContact2.Id, GDPR_Obscuration_Requested__c = true, 
							   Salesforce_Contact__c = testContact.Id)
		});
		ContactObfuscationProcessor.contactObscurationIsInProgress = true;
		Test.stopTest();
		
		Integer remainingCount = [SELECT COUNT() FROM BDP_Contact__c WHERE Id IN :bdpContactIdSet];
		System.assertEquals(0, remainingCount);
		
		Contact resultContact = [SELECT Id, GDPR_Obscuration_Requested__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
		System.assert(resultContact.GDPR_Obscuration_Requested__c, 'Contact Obscuration flag has not been updated.');
		
		BDP_Contact__c resultBDPContact = [SELECT Id, Last_Name__c, Salesforce_Contact__c FROM BDP_Contact__c 
										  WHERE F_Number__c = :relatedBdpContact1.F_Number__c LIMIT 1];
		System.assertEquals(resultContact.Id, resultBDPContact.Salesforce_Contact__C);
		System.assert(resultBDPContact.Last_Name__c.contains('GDPR'));
	}

	
	/*
	* @describe Method class tests obscuration process for BDP Contact, when one BDP Contact related to Salesforce Contact 
	* should be obscured, but another one remains unobscured. Next criterias are tested:
	* 1) Original Record is Deleted
	* 2) Obscured clone is created
	* 3) Original BDP Contact is updated to unset Salesforce Contact Lookup
	*/
	public static testMethod void testBDPContactObfuscationForSingleRecord() {
		Account defaultAccount = PrepareTestData.getDefaultAccount();
		Database.insert(defaultAccount);
		
		Contact testContact = PrepareTestData.getTestContact(defaultAccount.Id);
		Database.insert(testContact);
		
		BDP_Contact__c relatedBdpContact1 = PrepareTestData.getTestBDPContact(testContact.Id),
					   relatedBdpContact2 = PrepareTestData.getTestBDPContact(testContact.Id);
					   
		Database.insert(new List<BDP_Contact__c>{relatedBdpContact1, relatedBdpContact2});
		Set<Id> bdpContactIdSet = new Set<Id>{relatedBdpContact1.Id, relatedBdpContact2.Id};
		
		Test.startTest();
		ObfuscationProcessor.isDebugMode = true;
		Database.update(new BDP_Contact__c(Id = relatedBdpContact1.Id, GDPR_Obscuration_Requested__c = true));
		Test.stopTest();
		
		Integer remainingCount = [SELECT COUNT() FROM BDP_Contact__c WHERE Id IN :bdpContactIdSet];
		System.assertEquals(1, remainingCount);
		
		BDP_Contact__c resultBDPContact = [SELECT Id, Last_Name__c, Salesforce_Contact__c FROM BDP_Contact__c 
										  WHERE F_Number__c = :relatedBdpContact1.F_Number__c LIMIT 1];
		System.assertEquals(null, resultBDPContact.Salesforce_Contact__C);
		System.assert(resultBDPContact.Last_Name__c.contains('GDPR'));
	}	
	
	
	/*
	* @describe Method class tests obscuration process for BDP Contact, when obscuration is requested during the insert process 
	* should be obscured, but another one remains unobscured. Next criterias are tested:
	* 1) Original Record is Deleted
	* 2) Obscured clone is created
	* 3) Related Salesforce Contact Obscuration is requested
	*/
	public static testMethod void testBDPContactObfuscationOnInsert() {
		Account defaultAccount = PrepareTestData.getDefaultAccount();
		Database.insert(defaultAccount);
		
		Contact testContact = PrepareTestData.getTestContact(defaultAccount.Id);
		Database.insert(testContact);
		
		BDP_Contact__c relatedBdpContact = PrepareTestData.getTestBDPContact(testContact.Id);
		relatedBdpContact.GDPR_Obscuration_Requested__c = true;
		
		Test.startTest();
		ObfuscationProcessor.isDebugMode = true;
		Database.insert(relatedBdpContact);
		Test.stopTest();
		
		Integer remainingCount = [SELECT COUNT() FROM BDP_Contact__c WHERE Id = :relatedBdpContact.Id];
		System.assertEquals(0, remainingCount);
		
		BDP_Contact__c resultBDPContact = [SELECT Id, Last_Name__c, Salesforce_Contact__r.GDPR_Obscuration_Requested__c 
										  FROM BDP_Contact__c 
										  WHERE F_Number__c = :relatedBdpContact.F_Number__c LIMIT 1];
		System.assertEquals(true, resultBDPContact.Salesforce_Contact__r.GDPR_Obscuration_Requested__c);
		System.assert(resultBDPContact.Last_Name__c.contains('GDPR'));
	}	
}