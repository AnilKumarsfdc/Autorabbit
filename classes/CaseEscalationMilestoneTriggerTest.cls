/* --------------------------------------------------------------------------------------------------
     Name:            CaseEscalationMilestoneTrigger.cls 
     Description:     Apex class which tests Milestone Trigger, which caclulates estimated times for 
  	 Document Requested Milestones
    ------------------------------------------------------------------------------------------------ */

@isTest
public with sharing class CaseEscalationMilestoneTriggerTest {
    /*
    * @desription Calculate that MilestoneTrigger time is dependent on Days With Customer
    */
    @isTest private static void testCalculatedTime() {
    	User testUser = new User(Id = UserInfo.getUserId());
    	System.runAs(testUser) {
    		Account testAccount = PrepareTestData.getDefaultAccount();
    		insert testAccount;
    		
    		Integer daysLimit = CaseEscalationMilestoneTrigger.MILESTONE_DAYS_AFTER_ESCALATION - 1;
    		Integer daysWithCustomer = Math.round(Math.random() * daysLimit);
    		Case testCase = PrepareTestData.getDefaultCase(testAccount.Id);
    		testCase.Case_Pending_With_Customer__c = daysWithCustomer;
    		insert testCase;
    		
    		MilestoneType milestoneInfo = [SELECT Id FROM MilestoneType 
    									   WHERE Name=:CaseEscalationMilestoneTrigger.EXTENDED_MILSTONE_NAME
    									   LIMIT 1];
    		
    		Test.startTest();
    		CaseEscalationMilestoneTrigger milestoneTrigger = new CaseEscalationMilestoneTrigger();
    		Integer escalatedMinutes = milestoneTrigger.calculateMilestoneTriggerTime(testCase.Id, milestoneInfo.Id);
    		Test.stopTest();    		
    		
    		Integer expectedDays = CaseEscalationMilestoneTrigger.MILESTONE_DAYS_AFTER_ESCALATION - daysWithCustomer;
    		Integer escalatedDays = Math.round(escalatedMinutes / CaseEscalationMilestoneTrigger.MINUTES_IN_DAY);
    		System.assertEquals(expectedDays, escalatedDays, 'Number of escalated Days is not correct');
    	}
    }
}