/* --------------------------------------------------------------------------------------------------
  Name:            SendStrategyLightningControllerTest.cls 
  Description:     Test class which verifies apex controller functionality to send
  				   Relationship Plan / Strategy Plan as a PDF
  ------------------------------------------------------------------------------------------------ */
@isTest
public with sharing class SendStrategyLightningControllerTest {
	/**
	*@description Test that Relationship / Strategy Plan has been sent as PDF 
	**/
	private static testMethod void testSendRelationshipPlanAsPDF() {
		Relationship_Strategy_Plan__c defaultPlan = new Relationship_Strategy_Plan__c();
		Database.insert(defaultPlan);
		Account testAccount = PrepareTestData.getDefaultAccount();
		testAccount.Relationship_Plan__c = defaultPlan.Id;
		Database.insert(testAccount);
		
		String testEmail = UserInfo.getUserEmail();
		User runningUser = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
		System.runAs(runningUser) {			
			Test.startTest();
			Boolean strategyPlanHasBeenSent = SendStrategyLightningController.sendEmailFromPage(
				testAccount.Id, new List<String>{testEmail}
			);
			Test.stopTest();
			System.assert(strategyPlanHasBeenSent, 'Sending of Email Plan has been failed');
		}
	}    
}