/* --------------------------------------------------------------------------------------------------
   Name:            ReportingCountsIntegrationFlushTest.cls 
   Description:     Test Class which tests both Batch Job and Scheduled job for batch execution

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   23-Jan-2018         0.1         Vijay Sonawane       Intial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private with sharing class ReportingCountsIntegrationFlushTest{  
    
    /**
   * @Test data preparation
   * 
   **/
    @testSetup static void prepareData() {        
        List<Reporting_Counts_Integration__c> integrationObjectList=new List<Reporting_Counts_Integration__c>();
        for(Integer i=0;i<200;i++){        
            Reporting_Counts_Integration__c integrationObject = 
                            new Reporting_Counts_Integration__c(DB_Count__c=1, Diff_Count__c=2, Execution_Time__c=System.today(),
                                                                File_Count__c=1, Table_Name__c='Test Table');        
            integrationObjectList.add(integrationObject);
         }
         insert integrationObjectList;  
         
         List<Reporting_Counts_Integration__c> newIntegrationObjectList=new List<Reporting_Counts_Integration__c>();
         for(Reporting_Counts_Integration__c integrationObject : integrationObjectList){
            Test.setCreatedDate(integrationObject.Id, System.today()-8);  
            newIntegrationObjectList.add(integrationObject);
          }
          update newIntegrationObjectList;           
    }     
  
    /**
   * @description Checks Batch Job execution for all existing Reporting_Controls_Integration__c records deleted
   * 
   **/
   @isTest  private static void testBatchJobExecution() {        
        
         Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  ReportingCountsIntegrationFlushBatch batchObj = new ReportingCountsIntegrationFlushBatch();
              database.executeBatch(batchObj);
            }
          Test.stopTest();
          
          List<Reporting_Counts_Integration__c> resultList = [
            SELECT id
            FROM Reporting_Counts_Integration__c
          ];
          System.assertEquals(resultList.size(), 0);       
    } 
    
    /**
   * @description Checks Batch Job execution started by Scheduled Job
   * 
   **/
    @isTest  private static void testScheduledJobExecution() { 
          Test.startTest();
        	System.runAs(new User(Id = UserInfo.getUserId())){
            	String scheduleId = ReportingCountsIntegrationFlshSchedule.setupSheduleJob();
        	}
          Test.stopTest();        
          Integer batchCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'ReportingCountsIntegrationFlushBatch'];
          System.assert(batchCount > 0);        
    }          
}