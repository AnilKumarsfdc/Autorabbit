/* --------------------------------------------------------------------------------------------------
     Name:            ReportingCountsIntegrationFlushSchedule.cls 
     Description:     Schedulable job which starts ReportingCountsIntegrationFlushBatch batch.
     Test class:      ReportingCountsIntegrationFlushTest.cls 
    ------------------------------------------------------------------------------------------------ */
global with sharing class ReportingCountsIntegrationFlshSchedule implements Schedulable {  
  private static final String DEFAULT_JOB_NAME = 'ReportingCountsIntegrationFlushSchedule';
  private static final String DEFAULT_TEST_JOB_NAME = 'ReportingCountsIntegrationFlushTest';
  private static final String CRON_EXPRESSION = '0 0 1 * * ?';  
  /*
  * @description Main schedulable execute method which starts batch job
  */    
    global void execute(SchedulableContext SC) {
      ReportingCountsIntegrationFlushBatch batchObject = new ReportingCountsIntegrationFlushBatch();
      Database.executeBatch(batchObject, ReportingCountsIntegrationFlushBatch.DEFAULT_BATCH_SIZE);
    } 
  /*
  * @description Setups schedule job with default configuration
  */    
    global static String setupSheduleJob() {
       return System.schedule(
         Test.isRunningTest() ? DEFAULT_TEST_JOB_NAME : DEFAULT_JOB_NAME,
              CRON_EXPRESSION,new ReportingCountsIntegrationFlshSchedule ()
        );
    }
}