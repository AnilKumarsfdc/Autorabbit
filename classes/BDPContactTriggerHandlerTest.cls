/* --------------------------------------------------------------------------------------------------
   Name:            BDPContactTriggerHandlerTest.cls 
   Description:     Test Class functionality of BDPContactTrigger

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   21-April-2017          0.1       Sheshant Kashyap    
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private class BDPContactTriggerHandlerTest {
	/*
	* Test HasOptedOutOfEmail is populated sucessfully when new BDP Contact created for existing contact
	**/
	private static testMethod void testNewBDPContactCreated() {
		User testUser = new User(Id = UserInfo.getUserId());
    	System.runAs(testUser) {
			Account defaultAccount = PrepareTestData.getDefaultAccount();
			Database.insert(defaultAccount);
			
			Contact testContact = PrepareTestData.getTestContact(defaultAccount.Id);
			testContact.HasOptedOutOfEmail = false;
			testContact.GDPR_Salesforce_Mastered__c = true;
			Database.insert(testContact);
			
			BDP_Contact__c relatedBdpContact1 = PrepareTestData.getTestBDPContact(testContact.Id),
						   relatedBdpContact2 = PrepareTestData.getTestBDPContact(testContact.Id);
    		
    		relatedBDPContact1.Email_Opt_Out__c = false;
    		relatedBDPContact2.Email_Opt_Out__c = true;
    		
    		Test.startTest();
    		Database.insert(new List<BDP_Contact__c>{relatedBdpContact1, relatedBdpContact2});
    		Test.stopTest();
    		
    		Contact updatedContactData = [SELECT Id, HasOptedOutOfEmail, GDPR_Salesforce_Mastered__c
    									  FROM Contact
    									  WHERE Id = :testContact.Id
    									  LIMIT 1];
    		System.assertEquals(true, updatedContactData.HasOptedOutOfEmail);
    		System.assertEquals(false, updatedContactData.GDPR_Salesforce_Mastered__c);
    	}
	} 
	
	/*
	* Test EmailFlag is populated sucessfully when new BDP Contact created for existing contact
	**/
	private static testMethod void testNewBDPContactRelocated() {
		User testUser = new User(Id = UserInfo.getUserId());
    	System.runAs(testUser) {
			Account defaultAccount = PrepareTestData.getDefaultAccount();
			Database.insert(defaultAccount);
			
			Contact testContact = PrepareTestData.getTestContact(defaultAccount.Id);
			testContact.HasOptedOutOfEmail = true;
			testContact.GDPR_Salesforce_Mastered__c = false;
			Database.insert(testContact);
			
			Contact testContactNew = PrepareTestData.getTestContact(defaultAccount.Id);
			testContact.HasOptedOutOfEmail = false;
			testContact.GDPR_Salesforce_Mastered__c = true;
			Database.insert(testContactNew);
			
			BDPContactTriggerHandler.processSynchronously = true;
			BDP_Contact__c relatedBdpContact1 = PrepareTestData.getTestBDPContact(testContact.Id),
						   relatedBdpContact2 = PrepareTestData.getTestBDPContact(testContact.Id);
    		relatedBDPContact1.Email_Opt_Out__c = true;
    		relatedBDPContact2.Email_Opt_Out__c = false;
    		Database.insert(new List<BDP_Contact__c>{relatedBdpContact1, relatedBdpContact2});
    		
    		Test.startTest();
    		BDPContactTriggerHandler.processSynchronously = false;
    		Database.update(new BDP_Contact__c(
    			Id = relatedBdpContact1.Id,
    			Salesforce_Contact__c = testContactNew.Id
    		));
    		Test.stopTest();
    		
    		Contact updatedOldContactData = [SELECT Id, HasOptedOutOfEmail, GDPR_Salesforce_Mastered__c
    									  FROM Contact
    									  WHERE Id = :testContact.Id
    									  LIMIT 1];
    		Contact updatedNewContactData = [SELECT Id, HasOptedOutOfEmail, GDPR_Salesforce_Mastered__c
    									  FROM Contact
    									  WHERE Id = :testContactNew.Id
    									  LIMIT 1];
    		System.assertEquals(false, updatedOldContactData.HasOptedOutOfEmail);
    		System.assertEquals(false, updatedOldContactData.GDPR_Salesforce_Mastered__c);
    		System.assertEquals(true, updatedNewContactData.HasOptedOutOfEmail);
    		System.assertEquals(false, updatedNewContactData.GDPR_Salesforce_Mastered__c);
    	}
	} 	   
}