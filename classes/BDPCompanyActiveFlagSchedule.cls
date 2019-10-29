/* --------------------------------------------------------------------------------------------------
     Name:            BDPCompanyActiveFlagSchedule.cls 
     Description:     Schedulable job which starts BDPCompanyActiveFlagBatch batch.
  	 Test class:      BDPCompanyActiveFlagTest.cls 
    ------------------------------------------------------------------------------------------------ */
global with sharing class BDPCompanyActiveFlagSchedule implements Schedulable {
	private static final String DEFAULT_JOB_NAME = 'BDPCompanyActiveFlagSchedule';
	private static final String DEFAULT_TEST_JOB_NAME = 'BDPCompanyActiveFlagTest';
	private static final String CRON_EXPRESSION = '0 0 1 * * ?';
	
	/*
	* @description Main schedulable execute method which starts batch job
	*/    
    global void execute(SchedulableContext SC) {
    	BDPCompanyActiveFlagBatch batchObject = new BDPCompanyActiveFlagBatch(false);
    	Database.executeBatch(batchObject, BDPCompanyActiveFlagBatch.DEFAULT_BATCH_SIZE);
    }    
   
	/*
	* @description Setups schedule job with default configuration
	*/    
    global static String setupSheduleJob() {
   		return System.schedule(
   			Test.isRunningTest() ? DEFAULT_TEST_JOB_NAME : DEFAULT_JOB_NAME,
			CRON_EXPRESSION,
			new BDPCompanyActiveFlagSchedule()
		);
    }
}