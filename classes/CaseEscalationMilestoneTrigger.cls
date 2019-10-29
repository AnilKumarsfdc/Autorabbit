/* --------------------------------------------------------------------------------------------------
     Name:            CaseEscalationMilestoneTrigger.cls 
     Description:     Apex class which calculates number of days with Customer, which are allowed for
  	 a Milestone before and after Extension
     Test class:      CaseEscalationMilestoneTriggerTest.cls 
    ------------------------------------------------------------------------------------------------ */

global with sharing class CaseEscalationMilestoneTrigger implements Support.MilestoneTriggerTimeCalculator {
    private final static Integer MILESTONE_DAYS_BEFORE_ESCALATION = 30;
    @testVisible private final static Integer MILESTONE_DAYS_AFTER_ESCALATION = 60;
    @testVisible private final static String EXTENDED_MILSTONE_NAME = 'With Customer - Extension Received';
    @testVisible private final static Integer MINUTES_IN_DAY = 1440;
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
    	Case caseInfo = [SELECT Id, Case_With_Customer_Age__c, Case_Pending_With_Customer__c
    					 FROM Case
    					 WHERE Id = :caseId
    					 LIMIT 1];
        system.debug('@@@@@@@caseInfo' +caseInfo);
  						
    	MilestoneType milestoneInfo = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId LIMIT 1];
    	Integer totalDaysCount = (milestoneInfo.Name == EXTENDED_MILSTONE_NAME) ? MILESTONE_DAYS_AFTER_ESCALATION 
    																			: MILESTONE_DAYS_BEFORE_ESCALATION;
    	Integer daysUsed = (caseInfo.Case_With_Customer_Age__c != null) ? Integer.valueOf(caseInfo.Case_With_Customer_Age__c) 
    																	: 0;
        system.debug('@@@@@@@milestoneInfo' +milestoneInfo);
        system.debug('@@@@@@@totalDaysCount' +totalDaysCount);
        system.debug('@@@@@@@daysUsed' +daysUsed);
        system.debug('@@@@@@@returnVal' +Math.max((totalDaysCount - daysUsed) * MINUTES_IN_DAY, 0) + 1);
        
    	return Math.max((totalDaysCount - daysUsed) * MINUTES_IN_DAY, 0) + 1;
        
    }
}