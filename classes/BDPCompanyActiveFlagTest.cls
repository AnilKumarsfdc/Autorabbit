/* --------------------------------------------------------------------------------------------------
   Name:            BDPCompanyActiveFlagTest.cls 
   Description:     Test Class which tests both Batch Job and Scheduled job for batch execution

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   01-December-2017         0.1     Iegor Nechyporenko   Intial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private with sharing class BDPCompanyActiveFlagTest {
	private static final Integer MIN_JNUMBER = 10000000;
	private static final Integer MAX_JNUMBER = 80000000;

    /**
	 * @description Checks Batch Job execution for all existing BDP Companies
	 * 
	 **/
   @isTest  private static void testBatchJobExecution() {
   		User runningUser = new User(Id = UserInfo.getUserId());
		System.runAs(runningUser) {
	        Account testAccount = PrepareTestData.getDefaultAccount();
	        Database.insert(testAccount);
	        
	        Integer randomBdpNumber = MIN_JNUMBER + PrepareTestData.randomInt(MAX_JNUMBER);
	        
	        BDP_Company__c bdpCompany = new BDP_Company__c(
	        	Name = String.valueOf(randomBdpNumber), 
	        	Company__c = testAccount.Id, 
	        	BDP_Customer_Number__c= String.valueOf(randomBdpNumber),
	        	Active__c = false
	        );
	        Database.insert(bdpCompany);
	        

	        Reporting_Controls_Integration__c integrationObject = new Reporting_Controls_Integration__c(
	        	BDP_Identifier__c = randomBdpNumber,
	        	BDP_Type__c = 'J',
	        	Active__c = !bdpCompany.Active__c
	        );
	        Database.insert(integrationObject);
	        
	        Test.startTest();
	        BDPCompanyActiveFlagBatch.runBatchForAllRecords();
	        Test.stopTest();
	        
	        Reporting_Controls_Integration__c resultObjectObject = [
	        	SELECT Active__c 
	        	FROM Reporting_Controls_Integration__c
	        	WHERE Id = :integrationObject.Id
	        ];
	        System.assertEquals(bdpCompany.Active__c, resultObjectObject.Active__c);
		}		
    }    

    /**
	 * @description Checks Batch Job execution started by Scheduled Job
	 * 
	 **/
    @isTest  private static void testScheduledJobExecution() {
   		User runningUser = new User(Id = UserInfo.getUserId());
		System.runAs(runningUser) {
	        Account testAccount = PrepareTestData.getDefaultAccount();
	        Database.insert(testAccount);
	        
	        Integer randomBdpNumber = MIN_JNUMBER + PrepareTestData.randomInt(MAX_JNUMBER);
	        
	        BDP_Company__c bdpCompany = new BDP_Company__c(
	        	Name = String.valueOf(randomBdpNumber), 
	        	Company__c = testAccount.Id, 
	        	BDP_Customer_Number__c= String.valueOf(randomBdpNumber),
	        	Active__c = true
	        );
	        Database.insert(bdpCompany);
	        

	        Reporting_Controls_Integration__c integrationObject = new Reporting_Controls_Integration__c(
	        	BDP_Identifier__c = randomBdpNumber,
	        	BDP_Type__c = 'J',
	        	Active__c = !bdpCompany.Active__c
	        );
	        Database.insert(integrationObject);
	        
	        Test.startTest();
	        String scheduleId = BDPCompanyActiveFlagSchedule.setupSheduleJob();
	        Test.stopTest();
	        
	        Integer batchCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'BDPCompanyActiveFlagBatch'];
	        System.assert(batchCount > 0);
		}		
    }    
}