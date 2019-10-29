/* --------------------------------------------------------------------------------------------------
   Name:            DataFixerBatchTest.cls 
   Description:     Methods which tests successfull Batch execution

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   09-October-2017          0.1     Iegor Nechyporenko   Intial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
public with sharing class DataFixerBatchTest {
    private static final String TEST_RECORD_TYPE = 'Lending';
    private static final String TEST_PROFILE_NAME = 'SAN 2';
    private static final String TEST_FOLDER_NAME = 'Sales Docs';
	
	
    /*
	* @description Test, that Batch job will set default value to empty TP Rates
	*/
	public static testMethod void testTPRateFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Integer recordsToTest = 30;
			Opportunity[] opportunityList = new List<Opportunity>();
			for (Integer index = 0; index < recordsToTest; index++) {
				opportunityList.add(PrepareTestData.getOpportunityData(
					TEST_RECORD_TYPE, testAccount.Id
				));
			}
			Database.insert(opportunityList);
			
			Opportunity_Product__c[] productList = new List<Opportunity_Product__c>();
			Opportunity_Product__c product;
			for (Integer index = 0; index < recordsToTest; index++) {
				product = PrepareTestData.getOpportunityProduct(
					opportunityList.get(index).Id, TEST_RECORD_TYPE
				);
				product.TP_Rate__c = DataFixerBatch.EMPTY_TP_RATE;
				productList.add(product);
			}
			Database.insert(productList);
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.FIX_TP_RATE);
			Database.executeBatch(batchJob, recordsToTest);
			Test.stopTest();
			
			Set<Id> productIdSet = new Map<Id, Opportunity_Product__c>(productList).keySet();
			Integer fixedCount = [SELECT COUNT() FROM Opportunity_Product__c
				WHERE TP_Rate__c = :DataFixerBatch.PROPER_RATE
				  AND Id IN :productIdSet];
			System.assertEquals(recordsToTest, fixedCount);
		}
	}
	
    /*
	* @description Test, that Batch job will updateOpportunity values
	*/
	public static testMethod void testOpportunityFieldsFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Integer recordsToTest = 30;
			Opportunity[] opportunityList = new List<Opportunity>();
			for (Integer index = 0; index < recordsToTest; index++) {
				opportunityList.add(PrepareTestData.getOpportunityData(
					TEST_RECORD_TYPE, testAccount.Id
				));				
			}
			Database.insert(opportunityList);
			
			Opportunity_Product__c[] productList = new List<Opportunity_Product__c>();
			for (Integer index = 0; index < recordsToTest; index++) {
				productList.add(PrepareTestData.getOpportunityProduct(
					opportunityList.get(index).Id, TEST_RECORD_TYPE
				));
			}
			Database.insert(productList);
			
			for (Integer index = 0; index < recordsToTest; index++) {
				opportunityList.get(index).Primary_Product__c = null;
			}
			Database.update(opportunityList);
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.SET_OPPORTUNITY_VARIABLES);
			Database.executeBatch(batchJob, recordsToTest);
			Test.stopTest();
			
			Set<Id> productIdSet = new Map<Id, Opportunity>(opportunityList).keySet();
			Integer fixedCount = [SELECT COUNT() FROM Opportunity
				WHERE Id IN :productIdSet
				AND Primary_Product__c = null];
			System.assertEquals(0, fixedCount);
		}
	}		
		
    /*
	* @description Test, that Batch job will set Opportunity Product Lookup
	*/
	public static testMethod void testPrimaryProducLookupFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Integer recordsToTest = 30;
			Opportunity[] opportunityList = new List<Opportunity>();
			for (Integer index = 0; index < recordsToTest; index++) {
				opportunityList.add(PrepareTestData.getOpportunityData(
					TEST_RECORD_TYPE, testAccount.Id
				));				
			}
			Database.insert(opportunityList);
			
			Opportunity_Product__c[] productList = new List<Opportunity_Product__c>();
			for (Integer index = 0; index < recordsToTest; index++) {
				productList.add(PrepareTestData.getOpportunityProduct(
					opportunityList.get(index).Id, TEST_RECORD_TYPE
				));
			}
			Database.insert(productList);
			
			for (Integer index = 0; index < recordsToTest; index++) {
				opportunityList.get(index).Primary_Product_Lookup__c = null;
			}
			Database.update(opportunityList);
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.SET_PRIMARY_PRODUCT_LOOKUP);
			Database.executeBatch(batchJob, recordsToTest);
			Test.stopTest();
			
			Set<Id> productIdSet = new Map<Id, Opportunity>(opportunityList).keySet();
			Integer fixedCount = [SELECT COUNT() FROM Opportunity
				WHERE Id IN :productIdSet
				AND Primary_Product_Lookup__c = null];
			System.assertEquals(0, fixedCount);
		}
	}	
	
		
    /*
	* @description Test, that Batch job will set Fee Amount properly
	*/
	public static testMethod void testFeeAmountFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Opportunity oppRecord = PrepareTestData.getOpportunityData(
				TEST_RECORD_TYPE, testAccount.Id
			);				
			Database.insert(oppRecord);
			
			Opportunity_Product__c oppProduct = PrepareTestData.getOpportunityProduct(
				oppRecord.Id, GlobalConstants.OPP_PRODUCT_FEE_RECORD_TYPE
			);
			oppProduct.Estimated_Income__c = 500;
			oppProduct.Fee_Amount__c = null;
			Database.update(new Product2(
				Id = oppProduct.Product__c,
				Amortised_Income__c = false
			));
			Database.insert(oppProduct);
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.FIX_FEE_AMOUNT);
			Database.executeBatch(batchJob);
			Test.stopTest();
			
			Opportunity_Product__c resultProduct = [SELECT Fee_Amount__c, Estimated_Income__c
				FROM Opportunity_Product__c
				WHERE Id = :oppProduct.Id
				LIMIT 1];
			System.assertEquals(resultProduct.Estimated_Income__c, resultProduct.Fee_Amount__c);
		}
	}	
	
	/*
	* @description Test, that Batch job will set Estimated Income properly
	*/
	public static testMethod void testEstimatedIncomeFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Opportunity oppRecord = PrepareTestData.getOpportunityData(
				TEST_RECORD_TYPE, testAccount.Id
			);				
			Database.insert(oppRecord);
			
			Opportunity_Product__c oppProduct = PrepareTestData.getOpportunityProduct(
				oppRecord.Id, TEST_RECORD_TYPE
			);
			oppProduct.Facility_Amount__c = PrepareTestData.randomInt(10000);
			oppProduct.Gross_Margin__c = 25;
			oppProduct.TP_Rate__c = 5;
			Database.insert(oppProduct);
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.ESTIMATED_INCOME_RECALCULATION);
			Database.executeBatch(batchJob);
			Test.stopTest();
			
			Opportunity_Product__c resultProduct = [SELECT Estimated_Income_Formula__c, Estimated_Income__c,
					Estimated_Income_First_Year__c, Estimated_Income_First_Year_Copy__c 
				FROM Opportunity_Product__c
				WHERE Id = :oppProduct.Id LIMIT 1];
			System.assertEquals(resultProduct.Estimated_Income_Formula__c, resultProduct.Estimated_Income__c);
			System.assertEquals(resultProduct.Estimated_Income_First_Year_Copy__c, 
								resultProduct.Estimated_Income_First_Year__c);
		}
	}			
	
	/*
	* @description Test, that Batch job will successfully fix User Role
	*/
	public static testMethod void testUserRoleFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			User testUser = PrepareTestData.getRunningUser(TEST_PROFILE_NAME);
			testUser.LastName = DataFixerBatch.TEST_USER_LASTNAME;
			Database.insert(testUser);
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.UPDATE_USER_ROLES);
			Database.executeBatch(batchJob);
			Test.stopTest();
			
			User resultUser = [SELECT Id, Profile.Name, UserRole.Name FROM User 
							   WHERE Id = :testUser.Id LIMIT 1];
			System.assertEquals(resultUser.UserRole.Name, resultUser.Profile.Name);
		}
	}
    
    /*
	* @description Test, that Batch job will successfully fix Santander Id for Customer Companies
	*/
	public static testMethod void testCustomerCompanyFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
        Id customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DataFixerBatch.CUSTOMER_RECORD_TYPE).getRecordTypeId();
		System.runAs(currentUser){
			List<Account> testAccount = PrepareTestData.PrepareAccounts(3,true,DataFixerBatch.CUSTOMER_RECORD_TYPE);
			Integer recordsToTest = 3;

			Test.startTest();
            DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.UPDATE_CUSTOMER_COMPANY);
			Database.executeBatch(batchJob);
			Test.stopTest();
			
			Integer fixedCount = [SELECT COUNT() FROM Account
                                  WHERE RecordTypeId = :customerRecordType
                                  AND SAN_Id__c != null ];
			System.assertEquals(recordsToTest, fixedCount);
		}
	}
    
    /*
	* @description Test, that Batch job will successfully fix Last Contacted Date on Companies
	*/
	public static testMethod void testLastContactedDateFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
            
            Event testEvent = PrepareTestData.getDefaultEvent(testAccount.Id);
            Database.insert(testEvent);

			Test.startTest();
            DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.FIX_LAST_CONTACTED_DATE);
			Database.executeBatch(batchJob);
			Test.stopTest();
			
			Integer fixedCount = [SELECT COUNT() FROM Account
                                  WHERE Last_Contacted_Date__c != null
                                  AND Id= :testAccount.Id ];
			System.assertEquals(1, fixedCount);
		}
	}	
	/*
	* @description Test:
	*/
	public static testMethod void testInternationalFlagFix() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Opportunity oppRecord = PrepareTestData.getOpportunityData(
				TEST_RECORD_TYPE, testAccount.Id
			);				
			Database.insert(oppRecord);
			
			Opportunity_Product__c oppProduct = PrepareTestData.getOpportunityProduct(
				oppRecord.Id, TEST_RECORD_TYPE
			);
			oppProduct.Facility_Amount__c = PrepareTestData.randomInt(10000);
			oppProduct.Gross_Margin__c = 25;
			oppProduct.TP_Rate__c = 5;
			Database.insert(oppProduct);
			
			Database.update(new Product2(
				Id = oppProduct.Product__c,
				International__c = true
			));
			
			Test.startTest();
			DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.INTERNATIONAL_OPPORTUNITY_FLAG);
			Database.executeBatch(batchJob);
			Test.stopTest();
			
			Account resultAccount = [SELECT Expected_International_Date__c FROM Account WHERE Id = :testAccount.Id];
			System.assertEquals(oppRecord.CloseDate, 
								resultAccount.Expected_International_Date__c);

		}		
	}
    
    /*
	* @description Test, that Batch job will successfully create Sales Docs folder on existing companies
	*/
	public static testMethod void testCompanyFolderFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
            
            Company_Folder__c companyFolder = [SELECT ID,NAME FROM Company_Folder__c WHERE Name = : TEST_FOLDER_NAME];
            Database.delete(companyFolder);

			Test.startTest();
            	DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.FIX_COMPANY_FOLDER);
				Database.executeBatch(batchJob);
			Test.stopTest();
			
			Integer fixedCount = [SELECT COUNT() FROM Company_Folder__c
                                  WHERE NAME =: TEST_FOLDER_NAME
                                  AND Company__c = :testAccount.Id LIMIT 1];
			System.assertEquals(1, fixedCount);
		}
	}	
    
    /*
	* @description Test, that Batch job will update gdpr contact GDPR_Salesforce_Mastered__c field
	*/
	public static testMethod void testContactFixer() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
            
            Contact con = PrepareTestData.getTestContact(testAccount.Id);           
            Database.insert(con);

			Test.startTest();
            	DataFixerBatch batchJob = new DataFixerBatch(DataFixerBatch.JobType.FIX_CONTACTS);
				Database.executeBatch(batchJob);
			Test.stopTest();
			
			Contact conObj = [SELECT HasOptedOutOfEmail,GDPR_Salesforce_Mastered__c FROM Contact
                                  WHERE Id =: con.Id LIMIT 1];
			System.assertEquals(true, conObj.GDPR_Salesforce_Mastered__c);         
		}
	}	
}