/* --------------------------------------------------------------------------------------------------
   Name:            ReportingControlsIntegrationFlushTest.cls 
   Description:     Test Class which tests both Batch Job and Scheduled job for batch execution

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   23-Jan-2018         0.1         Vijay Sonawane       Intial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private with sharing class ReportingControlsIntegrationFlushTest{  
   /**
   * @Test data preparation
   * 
   **/
    @testSetup static void prepareData() {    
        Integer randomBdpNumber = GlobalConstants.MIN_JNUMBER + PrepareTestData.randomInt(GlobalConstants.MAX_JNUMBER);        
        List<Reporting_Controls_Integration__c> integrationObjectList=new List<Reporting_Controls_Integration__c>();
        for(integer i = 0; i<GlobalConstants.TEST_ITERATION;i++){     
            integrationObjectList.add(PrepareTestData.PrepareReportingControlIntegration(false,GlobalConstants.BDP_TYPE_J,randomBdpNumber));          
         }
         Database.insert(integrationObjectList);
         
         List<Reporting_Controls_Integration__c> newIntegrationObjectList=new List<Reporting_Controls_Integration__c>();
         for(Reporting_Controls_Integration__c integrationObject : integrationObjectList){
            Test.setCreatedDate(integrationObject.Id, System.today()-GlobalConstants.REPORTING_CONTROLS_FLUSH_DAYS_SINCE);  
            newIntegrationObjectList.add(integrationObject);
          }
          Database.update(newIntegrationObjectList);            
    }  
    /**
   * @description Checks Batch Job execution for all existing Reporting_Controls_Integration__c records deleted
   * 
   **/
   @isTest  private static void testBatchJobExecution() {
          Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  ReportingControlsIntegrationFlushBatch batchObj = new ReportingControlsIntegrationFlushBatch(false);
              database.executeBatch(batchObj);
            }
          Test.stopTest();          
          Integer totalCount = [
            SELECT COUNT()
            FROM Reporting_Controls_Integration__c 
            LIMIT :GlobalConstants.MAX_QUERY_LIMIT
          ];
          System.assertEquals(totalCount, 0);       
   }
    /**
   * @description Checks Batch Job execution started by Scheduled Job
   * 
   **/
    @isTest  private static void testScheduledJobExecution() {
          Test.startTest();
        	System.runAs(new User(Id = UserInfo.getUserId())){
          		String scheduleId = ReportingControlsIntegrationFlshSchedule.setupSheduleJob();
            }
          Test.stopTest();
          Integer batchCount = [SELECT COUNT() FROM AsyncApexJob 
          						WHERE ApexClass.Name =: GlobalConstants.REPORTING_CONTROLS_FLUSH_BATCH_CLASS 
          						LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
          System.assert(batchCount > 0);        
    }    
    
      /**
* @description tests Reporting Control Integration for F Record's BDP_Last_Updated_Date__c field update
**/
    
    @isTest  private static void testReportingControlIntegrationForFRecords() {
        Test.startTest(); 
            Integer randomBdpNumber = GlobalConstants.MIN_JNUMBER + PrepareTestData.randomInt(GlobalConstants.MAX_JNUMBER);
            List<BDP_Contact__c> bdpContactList = new List<BDP_Contact__c>();          
            List<Reporting_Controls_Integration__c> rci_F_List = new List<Reporting_Controls_Integration__c>();
            
            Account accountObj = PrepareTestData.getDefaultAccount();
            Database.insert(accountObj);
            Contact contactObj = PrepareTestData.getTestContact(accountObj.Id);
            Database.insert(contactObj);
            
            Date todaysDate = system.today();
        
            for(integer i = 1; i<=GlobalConstants.TEST_ITERATION;i++){          
                bdpContactList.add(PrepareTestData.getTestBDPContact(false,contactObj.Id,String.valueof(randomBdpNumber+i)));                
                Reporting_Controls_Integration__c rciFObj =PrepareTestData.PrepareReportingControlIntegration(false,GlobalConstants.BDP_TYPE_F,randomBdpNumber+i);
                 rciFObj.BDP_Last_Updated_Date__c = todaysDate.addDays(-1);
                 rciFObj.SFDC_Last_Updated_Date__c = todaysDate.addDays(5);
                rci_F_List.add(rciFObj);
            }            
            Database.insert(bdpContactList);      
            Database.insert(rci_F_List);        
        Test.stopTest();        
       
        BDP_Contact__c bcObj = [SELECT Id,BDP_Last_Updated_Date__c
                               FROM BDP_Contact__c
                               WHERE F_Number__c =: String.valueOf(randomBdpNumber+1)
                               LIMIT 1 ];
        System.assertEquals(true, bcObj.BDP_Last_Updated_Date__c == todaysDate.addDays(-1));
    }   
    /**
* @description tests Reporting Control Integration for J Record's BDP_Last_Updated_Date__c field update

* */
    
    @isTest  private static void testReportingControlIntegrationForJRecords() {
        
        Test.startTest(); 
       
            Integer randomBdpNumber = GlobalConstants.MIN_JNUMBER + PrepareTestData.randomInt(GlobalConstants.MAX_JNUMBER);
            
            List<BDP_Company__c> bdpCompanyList = new List<BDP_Company__c>();           
            List<Reporting_Controls_Integration__c> rci_J_List = new List<Reporting_Controls_Integration__c>();           
            
            Account accountObj = PrepareTestData.getDefaultAccount();
            Database.insert(accountObj);
            Contact contactObj = PrepareTestData.getTestContact(accountObj.Id);
            Database.insert(contactObj);
            
            Date todaysDate = system.today();           
            
            for(Integer i = 1; i<=GlobalConstants.TEST_ITERATION;i++){
                bdpCompanyList.add(PrepareTestData.getTestBDPCompany(false,accountObj.Id,String.valueOf(randomBdpNumber + i)));  
                Reporting_Controls_Integration__c rciJObj =PrepareTestData.PrepareReportingControlIntegration(false,GlobalConstants.BDP_TYPE_J,randomBdpNumber + i);
                rciJObj.BDP_Last_Updated_Date__c = todaysDate.addDays(-1);
                rciJObj.SFDC_Last_Updated_Date__c = todaysDate.addDays(5);
                rci_J_List.add(rciJObj);
                
            }
            Database.insert(bdpCompanyList);        
            Database.insert(rci_J_List);         
        Test.stopTest();
        
        BDP_Company__c bcObj = [SELECT Id,BDP_Last_Updated_Date__c
                               FROM BDP_Company__c
                               WHERE BDP_Customer_Number__c =: String.valueOf(randomBdpNumber+1)
                               LIMIT 1];
        System.assertEquals(true, bcObj.BDP_Last_Updated_Date__c == todaysDate.addDays(-1));
    }   
}