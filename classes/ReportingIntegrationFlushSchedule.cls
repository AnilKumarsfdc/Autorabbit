/* --------------------------------------------------------------------------------------------------
   Name:            ReportingIntegrationFlashSchedule.cls 
   Description:     Schedulable job which starts ReportingControlsIntegrationFlushBatch batch and
					ReportingCountsIntegrationFlushBatch batch	
   Test class:      ReportingIntegrationFlushTest.cls 
   Date             Version      Author              Summary of Changes 
   -----------      -------     -----------------   -------------------------------------------
   30-Jan-2018      0.1          Vijay Sonawane      Intial
  ------------------------------------------------------------------------------------------------ */
global with sharing class ReportingIntegrationFlushSchedule implements Schedulable {
  private static final String DEFAULT_JOB_NAME = 'ReportingIntegrationFlushSchedule';
  private static final String DEFAULT_TEST_JOB_NAME = 'ReportingIntegrationFlushTest';
  private static final String CRON_EXPRESSION = '0 0 1 * * ?';  
  /*
  * @description Main schedulable execute method which starts 2 batch jobs
  */    
    global void execute(SchedulableContext SC) {
        
      ReportingControlsIntegrationFlushBatch batchObject1 = new ReportingControlsIntegrationFlushBatch();
      Database.executeBatch(batchObject1, ReportingControlsIntegrationFlushBatch.DEFAULT_BATCH_SIZE);
      
      ReportingCountsIntegrationFlushBatch batchObject2 = new ReportingCountsIntegrationFlushBatch();
      Database.executeBatch(batchObject2, ReportingCountsIntegrationFlushBatch.DEFAULT_BATCH_SIZE);
        
    }
    
  /*
  * @description Setups schedule job with default configuration
  */    
    global static String setupSheduleJob() {
       return System.schedule(
         Test.isRunningTest() ? DEFAULT_TEST_JOB_NAME : DEFAULT_JOB_NAME,
              CRON_EXPRESSION,new ReportingIntegrationFlushSchedule()
        );
    }
}