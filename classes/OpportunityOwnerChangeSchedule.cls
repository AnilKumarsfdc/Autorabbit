/* --------------------------------------------------------------------------------------------------
   Name:            OpportunityOwnerChangeSchedule.cls 
   Description:     Schedulable job which starts OpportunityOwnerChangeBatch batch a
   Test class:      OpportunityOwnerChangeTest.cls 
   Date             Version      Author              Summary of Changes 
   -----------      -------     -----------------   -------------------------------------------
   07-Feb-2018      0.1          Vijay Sonawane      Intial
  ------------------------------------------------------------------------------------------------ */
global with sharing class OpportunityOwnerChangeSchedule implements Schedulable {
  private static final String DEFAULT_JOB_NAME = 'OpportunityOwnerChangeSchedule';
  private static final String DEFAULT_TEST_JOB_NAME = 'OpportunityOwnerChangeTest';
  private static final String CRON_EXPRESSION = '0 0 1 * * ?';  
  /*
  * @description Main schedulable execute method which starts batch job
  */    
    global void execute(SchedulableContext SC) {
        
      OpportunityOwnerChangeBatch batchObject = new OpportunityOwnerChangeBatch();
      Database.executeBatch(batchObject, OpportunityOwnerChangeBatch.DEFAULT_BATCH_SIZE);
    }
    
  /*
  * @description Setups schedule job with default configuration
  */    
    global static String setupSheduleJob() {
       return System.schedule(
         Test.isRunningTest() ? DEFAULT_TEST_JOB_NAME : DEFAULT_JOB_NAME,
              CRON_EXPRESSION,new OpportunityOwnerChangeSchedule() );
    }
}