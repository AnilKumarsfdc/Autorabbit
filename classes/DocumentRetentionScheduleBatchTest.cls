/* --------------------------------------------------------------------------------------------------
Name:            DocumentRetentionScheduleBatchTest.cls 
Description:     Test of DocumentRetentionScheduleBatch, which checks that both schedule
				 and batch parts of class are working fine.
------------------------------------------------------------------------------------------------ */
@isTest
private class DocumentRetentionScheduleBatchTest {
	/**
	*@description Prepopulate Custom Settings for testing
	*/
	@testSetup
	private static void setupTestConfigSettings() {       
		Account testAccount = PrepareTestData.getDefaultAccount();		
		Database.insert(testAccount);
		Database.insert(new Config_Settings__c(
			Document_Retention_Library__c = testAccount.Id
		));
	}    
	
	
	/**
	*@description Test batch execution job creates new link
	*/
	private static testMethod void testExecutionOfFullBatch() {
		User runningUser = PrepareTestData.getRunningUser('System Administrator');
		System.RunAs(runningUser) {        
			Id documentId = PrepareTestData.createTestContentDocumnet();
			Test.startTest();
			DocumentRetentionScheduleBatch.executeBatchForAllItems();
			Test.stopTest();
			
			Config_Settings__c config = Config_Settings__c.getInstance();
			Integer newLinksCount = [SELECT COUNT() FROM ContentDocumentLink
									 WHERE ContentDocumentId = :documentId
									 AND LinkedEntityId = :config.Document_Retention_Library__c];
			System.assertEquals(1, newLinksCount);
		}		
	}
	
	/**
	*@description Test schedule execution starts new batch job 
	*/
	private static testMethod void testScheduleSetupExecution() {
		User runningUser = PrepareTestData.getRunningUser('System Administrator');
		System.RunAs(runningUser) {        
			Id documentId = PrepareTestData.createTestContentDocumnet();
			Test.startTest();
			DocumentRetentionScheduleBatch.startScheulable();
			Test.stopTest();
			
			Integer requestedJobsCount = [SELECT COUNT() FROM AsyncApexJob
									 	  WHERE ApexClass.Name = 'DocumentRetentionScheduleBatch'];
			System.assert(requestedJobsCount > 0);
		}				
	}
}