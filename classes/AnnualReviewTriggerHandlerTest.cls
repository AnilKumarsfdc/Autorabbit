/* --------------------------------------------------------------------------------------------------
Name:            AnnualReviewTriggerHandlerTest.cls 
Description:     Test Class for  AnnualReviewTriggerHandler

Date                 Version     Author              Summary of Changes 
-----------          -------     -----------------   -------------------------------------------
28-August-2018       0.1       Vijay Sonawane    
------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class AnnualReviewTriggerHandlerTest {
    /**
	* @description Test for creating annual review and checking the task 
	* 
	**/
    private static testMethod void testAnnualReviewOnUpdate() {	
        Annual_Review_Plan__mdt annualReviewPlan = [SELECT Short_Form_Criteria_Met__c,Due_Date__c,Task_Subject__c
                                                    FROM Annual_Review_Plan__mdt
                                                    WHERE Short_Form_Criteria_Met__c = : GlobalConstants.ANNUAL_REVIEW_PLAN_IMMEDIATE
                                                    LIMIT 1];
        Account testAccount = PrepareTestData.getDefaultAccount();                
        Database.insert(testAccount);        
        
        Test.startTest();
        	testAccount.Annual_Review_Date__c = System.today();
        	Database.update(testAccount);
        Test.stopTest();
        
        Annual_Review__c testAnnualReview = [SELECT Id, Annual_Review_Date__c 
                                             FROM Annual_Review__c 
                                             WHERE Company__c = :testAccount.Id
                                             LIMIT 1];
        Task task = [SELECT Id, ActivityDate 
                     FROM Task 
                     WHERE WhatId = :testAnnualReview.Id 
                     AND Subject = :annualReviewPlan.Task_Subject__c
                     LIMIT :GlobalConstants.MIN_RANGE_SMALL];
        Integer priorDays = Integer.valueOf(annualReviewPlan.Due_Date__c);
        System.assertEquals(System.today().addDays(-priorDays),task.ActivityDate);
    }	
    
    /**
	* @description Test for rejected annual review 
	* 
	**/
    private static testMethod void testAnnualReviewOnReject() {
        
        Account testAccount = PrepareTestData.getDefaultAccount();        
        Database.insert(testAccount);
        
        testAccount.Annual_Review_Date__c=System.today();
        Database.update(testAccount);
        
        Annual_Review__c testAnnualReview = [SELECT Id, Annual_Review_Date__c, Status__c 
                                             FROM Annual_Review__c 
                                             WHERE Company__c =:testAccount.Id
                                             LIMIT 1];
        
        Test.startTest();
        	testAnnualReview.Status__c = GlobalConstants.ANNUAL_REVIEW_TASK_REJECTED;
        	Database.update(testAnnualReview);
        Test.stopTest();
        
        Account account = [SELECT Id, Annual_Review_Date__c,Active_Annual_Review__c 
                           FROM Account 
                           WHERE Id = :testAccount.Id
                           LIMIT :GlobalConstants.MIN_RANGE_SMALL];
        System.assertEquals(null, account.Annual_Review_Date__c);
        System.assertEquals(null, account.Active_Annual_Review__c);
    }	
    
    
    /**
	* @description Test for annual review date change 
	* 
	**/
    private static testMethod void testAnnualReviewDateChange() {
        Annual_Review_Plan__mdt annualReviewPlan = [SELECT Short_Form_Criteria_Met__c,Due_Date__c,Task_Subject__c
                                                    FROM Annual_Review_Plan__mdt
                                                    WHERE Short_Form_Criteria_Met__c = : GlobalConstants.ANNUAL_REVIEW_PLAN_IMMEDIATE
                                                    LIMIT 1];
        Account testAccount = PrepareTestData.getDefaultAccount();        
        Database.insert(testAccount);        
        testAccount.Annual_Review_Date__c=System.today();
        Database.update(testAccount);
        
        Test.startTest();
        	testAccount.Annual_Review_Date__c = System.today().addDays(1); // +1 day
        	Database.update(testAccount);
        Test.stopTest();
        
        Annual_Review__c testAnnualReview = [SELECT Id, Annual_Review_Date__c, Status__c 
                                             FROM Annual_Review__c 
                                             WHERE Company__c =:testAccount.Id
                                             LIMIT :GlobalConstants.MIN_RANGE_SMALL];
        Task task = [SELECT Id, ActivityDate 
                     FROM Task 
                     WHERE WhatId = :testAnnualReview.Id 
                     AND Subject = :annualReviewPlan.Task_Subject__c
                     LIMIT :GlobalConstants.MIN_RANGE_SMALL];
        Integer priorDays = Integer.valueOf(annualReviewPlan.Due_Date__c);
        System.assertEquals(System.today().addDays(-priorDays + 1),task.ActivityDate);
    }
}