/**
  * Name:        TaskTriggerHandlerTest.cls
  * Description: Test Class for TaskTriggerHandler Class           
  * Created By:  Vijay R. Sonawane 
  * 
  **/
@isTest(SeeAllData = false)
Private class TaskTriggerHandlerTest { 
    private static final String ERROR_MESSAGE = 'You don\'t have permission to delete current task';
    private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';    
    private static final String SAN2_PROFILE = 'SAN 2';
    /**
     * @description Checks that task owner can delete task record
     **/
    @isTest private static void testTaskDeleteByOwner() {
        
        User usr = PrepareTestData.getRunningUser(SYSTEM_ADMIN_PROFILE);
        Database.insert(usr);
       
        Task tsk = new Task();
       
        System.runAs(usr){
            Account testAccount = PrepareTestData.getDefaultAccount();
            Database.insert(testAccount);
            tsk.WhatID = testAccount.Id;
            tsk.OwnerId = usr.Id;
            tsk.Subject ='Test';
            tsk.Status = 'Not Started';
            tsk.Priority = 'Normal';           
            Database.insert(tsk); 
       
            Test.startTest();
                Database.Delete(tsk);
                List<Task> taskList = [SELECT Id,Subject FROM Task WHERE Id =: tsk.Id LIMIT 1];
            Test.stopTest();
            
            System.assertEquals(0, taskList.size());
        }
    }
    
    /**
     * @description Checks that non -owner can't delete task record
     **/
    @isTest private static void testTaskDeleteByNonOwner() {
        
        User usr1 = PrepareTestData.getRunningUser(SYSTEM_ADMIN_PROFILE);
        User usr2 = PrepareTestData.getRunningUser(SAN2_PROFILE);
        
        List<User> l_user = new List<User>();
        l_user.add(usr1);
        l_user.add(usr2);
        Database.insert(l_user);
        
        Task tsk = new Task();        
        System.runAs(usr1){
            Account testAccount = PrepareTestData.getDefaultAccount();
            Database.insert(testAccount);
            Case testCase = PrepareTestData.getDefaultCase(testAccount.Id);
            Database.insert(testCase);
            tsk.WhatID = testAccount.Id;
            tsk.OwnerId = usr1.Id;
            tsk.Subject ='Test';
            tsk.Status = 'Not Started';
            tsk.Priority = 'Normal';           
            Database.insert(tsk);
            
            tsk.ownerId = usr2.Id;
            Database.update(tsk);
        }        
        System.runAs(usr2){          
            try{
                Test.startTest();
                	Database.Delete(tsk);
                Test.stopTest(); 
            }catch(Exception ex){                     
                System.Assert(ex.getMessage().contains(ERROR_MESSAGE));
            }
        }
    } 
    
    /**
     * @description Checks that when all task related to annual review is completed 
     * then annual Review should be completed
     **/
    @isTest private static void testAllClosedTask() {
     	Account testAccount = PrepareTestData.getDefaultAccount();                
		Database.insert(testAccount);  
		 
		Annual_Review__c testAnnualReview = PrepareTestData.getDefaultAnnualReview(testAccount.Id);
		testAnnualReview.Annual_Review_Date__c = System.today();
        testAnnualReview.Short_Form_Criteria_Met__c = GlobalConstants.ANNUAL_REVIEW_CRITERIA_YES;
		Database.insert(testAnnualReview);
        
		Test.startTest();
       
		List<Task> taskToUpdate = new List<Task>();
		
		for(Task taskObj:[SELECT id,status FROM task 
                                      WHERE whatId = :testAnnualReview.id 
                                      LIMIT :GlobalConstants.MAX_QUERY_LIMIT]){
			taskObj.status = GlobalConstants.ANNUAL_REVIEW_TASK_COMPLETED;
			taskToUpdate.add(taskObj);		
		}
		
		Database.update(taskToUpdate);  
        Test.stopTest();
        
		Annual_Review__c annualReviewObj = [SELECT id,Status__c FROM Annual_Review__c 
                                                   WHERE id = :testAnnualReview.id LIMIT 1];		
        System.assertEquals(GlobalConstants.ANNUAL_REVIEW_TASK_COMPLETED, annualReviewObj.Status__c);
		
     }
    
    /**
     * @description Checks that when all task related to annual review is not completed 
     * then annual Review should be not completed
     **/
    @isTest private static void testNotAllClosedTask() {
     	Account testAccount = PrepareTestData.getDefaultAccount();                
		Database.insert(testAccount);  
        
		Annual_Review__c testAnnualReview = PrepareTestData.getDefaultAnnualReview(testAccount.Id);
		testAnnualReview.Annual_Review_Date__c = System.today();
        testAnnualReview.Short_Form_Criteria_Met__c = GlobalConstants.ANNUAL_REVIEW_CRITERIA_YES;
		Database.insert(testAnnualReview);  
        
		Test.startTest();
		List<Task> taskList = [SELECT id,status FROM task 
                                      WHERE whatId = :testAnnualReview.id LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
        taskList.remove(0);
        
		List<Task> taskToUpdate = new List<Task>();		
		for(Task taskObj:taskList){
			taskObj.status = GlobalConstants.ANNUAL_REVIEW_TASK_COMPLETED;
			taskToUpdate.add(taskObj);		
		}
        
		Database.update(taskToUpdate); 
        Test.stopTest();
        
		Annual_Review__c annualReviewObj = [SELECT id,Status__c FROM Annual_Review__c 
                                                   WHERE id = :testAnnualReview.id LIMIT 1];
		
        system.assertNotEquals(GlobalConstants.ANNUAL_REVIEW_TASK_COMPLETED, annualReviewObj.Status__c);
		
     }
}