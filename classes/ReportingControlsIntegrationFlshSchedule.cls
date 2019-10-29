/* --------------------------------------------------------------------------------------------------
     Name:            ReportingControlsIntegrationFlushSchedule.cls 
     Description:     Schedulable job which starts ReportingControlsIntegrationFlushBatch batch.
     Test class:      ReportingControlsIntegrationFlushTest.cls 
    ------------------------------------------------------------------------------------------------ */
global with sharing class ReportingControlsIntegrationFlshSchedule implements Schedulable {
  private static final String DEFAULT_JOB_NAME = 'ReportingControlsIntegrationFlushSchedule';
  private static final String DEFAULT_TEST_JOB_NAME = 'ReportingControlsIntegrationFlushTest';
  private static final String CRON_EXPRESSION = '0 0 1 * * ?';  
  /*
  * @description Main schedulable execute method which starts batch job
  */    
    global void execute(SchedulableContext SC) {
      ReportingControlsIntegrationFlushBatch batchObject = new ReportingControlsIntegrationFlushBatch();
      Database.executeBatch(batchObject, ReportingControlsIntegrationFlushBatch.DEFAULT_BATCH_SIZE);
    }
  /*
  * @description Setups schedule job with default configuration
  */    
    global static String setupSheduleJob() {
       return System.schedule(
         Test.isRunningTest() ? DEFAULT_TEST_JOB_NAME : DEFAULT_JOB_NAME,
              CRON_EXPRESSION,new ReportingControlsIntegrationFlshSchedule()
        );
    }
}