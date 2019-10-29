/**************************************************************
 * Class: ShareHoldingSyncReset
 * Description: Batch Apex class to Clean Up and Reset Sync Job
 * Created Date: 13/06/2019
 * 
 * Version History
 * 
 * Version		Modified By 		Modified Date 		Description
 * 0.1			Santandar CRM		13/06/2019		
 * **********************************************************/	
global with sharing class ShareHoldingSyncReset implements Database.Batchable<sObject>{
    
    /*********************************************************
     * Method: start
     * Description:Query the Shareholding__c for IsNeworUpdatedByExternalProvider__c = TRUE records
     * Parameter: Database.BatchableContext BC
     * Return: Database.getQueryLocator
     * *****************************************************/
global Database.querylocator start(Database.BatchableContext BC){
        
        String query = 'select id,IsNeworUpdatedByExternalProvider__c from Shareholding__c where IsNeworUpdatedByExternalProvider__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    /*********************************************************
     * Method: execute
     * Description: Update the Records
     * Parameter: List<sObject> scope
     * Return:
     * *****************************************************/
    global void execute(Database.BatchableContext BC, List<Shareholding__c> scope){

        try{
            if(scope !=null){
	for(Shareholding__c  sh : scope)
	{
		sh.IsNeworUpdatedByExternalProvider__c = FALSE;
	}
	update scope;
            }   
    }
        catch (Exception exc) {ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CalloutAttemptController','secureCallout', exc, 'ERROR');} 
    }
    /*********************************************************
     * Method:finish
     * Description:Update the Records
     * Parameter:List<sObject> scope
     * Return:
     * *****************************************************/
    global void finish(Database.BatchableContext BC){

	LegislationSyncCleanup callclean = new LegislationSyncCleanup();
	database.executebatch(callclean);
        
    }
}