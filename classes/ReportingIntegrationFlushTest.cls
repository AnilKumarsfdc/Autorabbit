/* --------------------------------------------------------------------------------------------------
   Name:            ReportingIntegrationFlushTest.cls 
   Description:     Test Class which tests both Batch Job and Scheduled job for below batch execution
					1.ReportingControlsIntegrationFlushBatch
					2.ReportingCountsIntegrationFlushBatch
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   30-Jan-2018         0.1         Vijay Sonawane       Intial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private with sharing class ReportingIntegrationFlushTest{ 
    
     private static final Integer MIN_JNUMBER = 10000000;
     private static final Integer MAX_JNUMBER = 80000000;    
   
    /**
    * @Test data preparation for  Reporting_Controls_Integration__c 
    *                             and Reporting_Counts_Integration__c objects
    **/
    @testSetup static void prepareData() {    
        
        Integer randomBdpNumber = MIN_JNUMBER + PrepareTestData.randomInt(MAX_JNUMBER);        
        List<Reporting_Controls_Integration__c> integrationControlObjectList=new List<Reporting_Controls_Integration__c>();
        for(Integer i=0;i<200;i++){        
            Reporting_Controls_Integration__c integrationControlObject = 
                            new Reporting_Controls_Integration__c(BDP_Identifier__c = randomBdpNumber,
                                                                BDP_Type__c = 'J',
                                                                Active__c = true);        
            integrationControlObjectList.add(integrationControlObject);
         }
         Database.insert(integrationControlObjectList);
         
         List<Reporting_Controls_Integration__c> newIntegrationControlObjectList=new List<Reporting_Controls_Integration__c>();
         for(Reporting_Controls_Integration__c integrationControlObject : integrationControlObjectList){
            Test.setCreatedDate(integrationControlObject.Id, System.today()-9);  
            newIntegrationControlObjectList.add(integrationControlObject);
          }
         Database.update(newIntegrationControlObjectList); 
        
        
        List<Reporting_Counts_Integration__c> integrationCountObjectList=new List<Reporting_Counts_Integration__c>();
        for(Integer i=0;i<200;i++){        
            Reporting_Counts_Integration__c integrationCountObject = 
                            new Reporting_Counts_Integration__c(DB_Count__c=1, Diff_Count__c=2, Execution_Time__c=System.today(),
                                                                File_Count__c=1, Table_Name__c='Test Table');        
            integrationCountObjectList.add(integrationCountObject);
         }
         Database.insert(integrationCountObjectList);  
         
         List<Reporting_Counts_Integration__c> newIntegrationCountObjectList=new List<Reporting_Counts_Integration__c>();
         for(Reporting_Counts_Integration__c integrationCountObject : integrationCountObjectList){
            Test.setCreatedDate(integrationCountObject.Id, System.today()-9);  
            newIntegrationCountObjectList.add(integrationCountObject);
          }
          Database.update(newIntegrationCountObjectList);           
    }     
  
    /**
    * @description Checks Batch Job execution for deleting all existing Reporting_Controls_Integration__c records 
    * created 7 days before   
    **/
   @isTest  private static void testBatchJobExecution1() {        
        
         Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  ReportingControlsIntegrationFlushBatch batchObj = new ReportingControlsIntegrationFlushBatch();
              database.executeBatch(batchObj);
            }
          Test.stopTest();
          
          List<Reporting_Controls_Integration__c> resultList = [SELECT id
            													FROM Reporting_Controls_Integration__c 
                                                                LIMIT 1000];
          System.assertEquals(resultList.size(), 0);       
    } 
    
    /**
    * @description Checks Batch Job execution for deleting all existing Reporting_Counts_Integration__c records 
    * created 7 days before   
    **/
   @isTest  private static void testBatchJobExecution2() {        
        
         Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  ReportingCountsIntegrationFlushBatch batchObj = new ReportingCountsIntegrationFlushBatch();
              database.executeBatch(batchObj);
            }
          Test.stopTest();
          
          List<Reporting_Counts_Integration__c> resultList = [SELECT id
            												  FROM Reporting_Counts_Integration__c 
                                                              LIMIT 1000];          
          System.assertEquals(resultList.size(), 0);       
    } 
    
     /**
     * @description Checks Batch Job execution for all existing Reporting_Controls_Integration__c records 
     * created today only   
     **/
   @isTest  private static void testBatchJobExecution3() {        
        Integer randomBdpNumber = MIN_JNUMBER + PrepareTestData.randomInt(MAX_JNUMBER);        
        List<Reporting_Controls_Integration__c> integrationControlObjectList=new List<Reporting_Controls_Integration__c>();
        for(Integer i=0;i<100;i++){        
            Reporting_Controls_Integration__c integrationControlObject = 
                            new Reporting_Controls_Integration__c(BDP_Identifier__c = randomBdpNumber,
                                                                BDP_Type__c = 'J',
                                                                Active__c = true);        
            integrationControlObjectList.add(integrationControlObject);
         }
         Database.insert(integrationControlObjectList) ;
       
         Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  ReportingControlsIntegrationFlushBatch batchObj = new ReportingControlsIntegrationFlushBatch(true);
              database.executeBatch(batchObj);
            }
          Test.stopTest();
          
          List<Reporting_Controls_Integration__c> resultList = [SELECT id
           														FROM Reporting_Controls_Integration__c 
                                                                LIMIT 1000];
          System.assertEquals(resultList.size(), 200);       
    } 
    /**
   * @description Checks two Batch Job execution started by this Scheduled Job
   * 
   **/
    @isTest  private static void testScheduledJobExecution() { 
          Test.startTest();
        	System.runAs(new User(Id = UserInfo.getUserId())){
            	ReportingIntegrationFlushSchedule.setupSheduleJob();
        	}
          Test.stopTest();        
          Integer batchCount = [SELECT COUNT() FROM AsyncApexJob 
                                WHERE ApexClass.Name = 'ReportingCountsIntegrationFlushBatch' 
                                OR ApexClass.Name = 'ReportingControlsIntegrationFlushBatch' LIMIT 1];
          System.assert(batchCount > 0);        
    }          
}