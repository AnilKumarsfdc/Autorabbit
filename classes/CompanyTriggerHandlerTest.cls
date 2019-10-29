/* --------------------------------------------------------------------------------------------------
     Name:            CompanyTriggerHandlerTest.cls 
     Description:     Test Class for Aura controller CompanyTriggerHandler
  <EOF>
     Date                 Version     Author              Summary of Changes 
     -----------          -------     -----------------   -------------------------------------------
     14-February-2017       0.1       Rohit Middha    
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class CompanyTriggerHandlerTest {
	
	/**
	 * @description Test for creating case and checking the task 
	 * 
	 **/
	@isTest private static void runPositiveTests()
	{		
		User usr = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);

		List<Santander_Lending_Policy__c> slpSettingList = new List<Santander_Lending_Policy__c> ();
		Santander_Lending_Policy__c setting1 = new Santander_Lending_Policy__c();
		setting1.Name = GlobalConstants.SIC_CODE1;
		setting1.SIC_Code__c = GlobalConstants.SIC_CODE1;
		setting1.Brag_Status__c = GlobalConstants.BRAG_STATUS1;
		setting1.Sector_Policy__c = GlobalConstants.SECTOR_POLICY;
		slpSettingList.add(setting1);

		Santander_Lending_Policy__c setting2 = new Santander_Lending_Policy__c();
		setting2.Name = GlobalConstants.SIC_CODE2;
		setting2.SIC_Code__c = GlobalConstants.SIC_CODE2;
		setting2.Brag_Status__c = GlobalConstants.BRAG_STATUS2;
		setting2.Sector_Policy__c = GlobalConstants.SECTOR_POLICY;
		slpSettingList.add(setting2);
		Database.insert(slpSettingList);

		System.RunAs(usr) {

			List<Account> accountList = new List<Account> ();
            List<Contact> contactList = new List<Contact> ();
			Account account;
			for (integer i = 0; i< 3; i++) {
				account = new Account();
				account.Name = GlobalConstants.TEST_NAME + i;
				account.UK_SIC_Code_2007__c = GlobalConstants.SIC_CODE1;
				accountList.add(account);
			}
			Database.insert(accountList);

			test.startTest();
			Account acc1 = [SELECT Name, Primary_Contact__c, UK_SIC_Code_2007__c, Brag_Status__c, Sector_Policy_applied__c
			                FROM Account LIMIT 1];

			test.stopTest();

			system.assertEquals(GlobalConstants.BRAG_STATUS1, acc1.Brag_Status__c);
			system.assertEquals(GlobalConstants.SECTOR_POLICY, acc1.Sector_Policy_applied__c);

			//Updating Existing Account
			acc1.UK_SIC_Code_2007__c = GlobalConstants.SIC_CODE2;
			Database.update(acc1);

			Account acc1Updated = [SELECT Name, Primary_Contact__c, UK_SIC_Code_2007__c, Brag_Status__c, Sector_Policy_applied__c
			                       FROM Account LIMIT 1];
			system.assertEquals(GlobalConstants.BRAG_STATUS2, acc1Updated.Brag_Status__c);
			system.assertEquals(GlobalConstants.SECTOR_POLICY, acc1Updated.Sector_Policy_applied__c);
		}
	}
	
	
	/**
	* Checks whether Banking Date is populate properly on creation
	**/ 
	private static testMethod void testBankingDateOnCreation() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE Name=:GlobalConstants.CUSTOMER_RECORD_TYPE
                                        LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		Account testAccount = PrepareTestData.getDefaultAccount();
		testAccount.RecordTypeId = customerRecordType.Id;
		
		Test.startTest();
		Database.insert(testAccount);
		Database.update(new Account(
			Id = testAccount.Id,
			UK_SIC_Code_2007__c = GlobalConstants.SIC_CODE1
		));
		Test.stopTest();
		
		Account resultAccount = [SELECT Id, New_To_Bank_Date__c, CreatedDate 
                                 FROM Account 
                                 WHERE Id = :testAccount.Id
                                 LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		Date createdDate =  Date.newInstance(resultAccount.CreatedDate.year(), 
											 resultAccount.CreatedDate.month(), 
											 resultAccount.CreatedDate.day());
		System.assertEquals(createdDate, resultAccount.New_To_Bank_Date__c);
	}
	
	/**
	*@description Test that newly created Relationship/Strategy plan is successfully updated when linked via Lightning. 
	**/
	private static testMethod void testRelationshipPlanNameAssignments() {
		Account testAccount1 = PrepareTestData.getDefaultAccount(),
				testAccount2 = PrepareTestData.getDefaultAccount();
		Database.insert(new List<Account>{testAccount1, testAccount2});
		Relationship_Strategy_Plan__c defaultPlan = new Relationship_Strategy_Plan__c();
		Database.insert(defaultPlan);
		
		User runningUser = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
		System.runAs(runningUser) {			
			Test.startTest();
			testAccount1.Relationship_Plan__c = defaultPlan.Id;
			testAccount2.Relationship_Plan__c = defaultPlan.Id;
			Database.update(new List<Account>{testAccount1, testAccount2});
			Test.stopTest();
		}
		
		Relationship_Strategy_Plan__c resultPlan = [SELECT Id, Name FROM Relationship_Strategy_Plan__c
													WHERE Id = :defaultPlan.Id
													LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		System.assertEquals(testAccount1.Name, resultPlan.Name);
	}
	
		
	/**
	*@description Checks whether Banking Date is populate properly on update
	**/ 
	private static testMethod void testBankingDateOnUpdate() {
		RecordType customerRecordType = [SELECT Id FROM RecordType 
                                         WHERE Name=:GlobalConstants.CUSTOMER_RECORD_TYPE
                                         LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		RecordType prospectRecordType = [SELECT Id FROM RecordType 
                                         WHERE Name=:GlobalConstants.PROSPECT_RECORD_TYPE
                                         LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		Account testAccount = PrepareTestData.getDefaultAccount();
		testAccount.RecordTypeId = customerRecordType.Id;
		Database.insert(testAccount);
		
		Test.startTest();
		Database.update(new Account(
			Id = testAccount.Id,
			RecordTypeId = prospectRecordType.Id
		));
		Test.stopTest();
		
		Account resultAccount = [SELECT Id, New_To_Bank_Date__c, LastModifiedDate FROM Account 
                                 WHERE Id = :testAccount.Id
                                 LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		Date lastModifiedDate =  Date.newInstance(resultAccount.LastModifiedDate.year(), 
											 	  resultAccount.LastModifiedDate.month(), 
											 	  resultAccount.LastModifiedDate.day());
		System.assertEquals(lastModifiedDate, resultAccount.New_To_Bank_Date__c);
	}
	
		
	/**
	* Ensures that Primary Contact is not added on creation
	**/ 
	private static testMethod void testPrimaryContactOnCreation() {
		//TODO Add run as to test methods
		Account testAccount = PrepareTestData.getDefaultAccount();
		Contact testContact = new Contact(LastName = GlobalConstants.TEST_NAME, 
                                          AccountId = testAccount.Id
                                        );
		
		Test.startTest();
		Database.insert(testAccount);
		Database.insert(testContact);

		//TODO try catch is not needed in test methods unless exception throwing process is tested
		try{	        
			Database.update(new Account(
				Id = testAccount.Id,
				UK_SIC_Code_2007__c = GlobalConstants.SIC_CODE1,
				Primary_Contact__c = testContact.Id
			));
		}
		catch (Exception exc){
			//throw exc;
		}
		
		Test.stopTest();
		
		Account resultAccount = [SELECT Id, Primary_Contact__c 
                                 FROM Account 
                                 WHERE Id = :testAccount.Id
                                 LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		
		System.assertEquals(null, resultAccount.Primary_Contact__c);
	}
	
	/**
	* Checks whether correct Primary Contact is populated properly on update
	**/ 
	private static testMethod void testPrimaryContactOnUpdate() {
		
		Account testAccount = PrepareTestData.getDefaultAccount();
		Database.insert(testAccount);

		Contact testContact = new Contact(LastName=GlobalConstants.TEST_NAME, AccountId= testAccount.Id);
		Database.insert(testContact);

		Test.startTest();
		//TODO try catch is not needed in test methods
		try{	        
			Database.update(new Account(
				Id = testAccount.Id,
				Primary_Contact__c = testContact.Id
			));
		}
		catch (Exception exc){
			throw exc;
		}
		
		Test.stopTest();
		
		Account resultAccount = [SELECT Id, Primary_Contact__c 
                                 FROM Account 
                                 WHERE Id = :testAccount.Id
                                 LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		System.assertEquals(testContact.Id, resultAccount.Primary_Contact__c);
	}	
    
    /**
	* Checks whether annual review is created on populating annual review date on update
	**/ 
	private static testMethod void testAnnualReviewOnUpdate() {
		
		Account testAccount = PrepareTestData.getDefaultAccount();
		Database.insert(testAccount);

		Test.startTest();
		//TODO try/catch is not needed here
		try{	        
			 testAccount.Annual_Review_Date__c = System.today();
        	 Database.update(testAccount);
		}
		catch (Exception exc){
			throw exc;
		}		
		Test.stopTest();
		
		Annual_Review__c annualReview = [SELECT Id, Annual_Review_Date__c 
                                         FROM Annual_Review__c 
                                         WHERE Company__c = :testAccount.Id
                                         LIMIT :GlobalConstants.MIN_RANGE_SMALL];
		System.assertEquals(system.today(), annualReview.Annual_Review_Date__c);
	}	
    
     /**
	* Checks whether task ownership is changed on changin company ownership
	**/ 
	private static testMethod void testAnnualReviewTaskOwnershipChange() {
        List<User> userList = new List<User>();
		User usr1 = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
        userList.add(usr1);
        User usr2 = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
        userList.add(usr2);
        Database.insert(userList);
		Account testAccount = PrepareTestData.getDefaultAccount();
        testAccount.OwnerId = usr1.Id;
		Database.insert(testAccount);
        Annual_Review__c testAnnualReview = PrepareTestData.getDefaultAnnualReview(testAccount.Id);
        Database.insert(testAnnualReview);
		Test.startTest();
		//TODO try/catch is not needed here
		try{	        
			  testAccount.OwnerId =usr2.Id;
              testAccount.Active_Annual_Review__c=testAnnualReview.Id;
              Database.update(testAccount);
		}
		catch (Exception e){
			throw e;
		}		
		Test.stopTest();
		
		List<Task> taskList = [SELECT Id, OwnerId 
                                         FROM Task 
                                         WHERE WhatId =: testAnnualReview.Id
                              			 LIMIT :GlobalConstants.MIN_RANGE_SMALL];
        System.assertEquals(true, taskList.size()>0);
		System.assertEquals(usr2.Id, taskList[0].OwnerId);
	}
}