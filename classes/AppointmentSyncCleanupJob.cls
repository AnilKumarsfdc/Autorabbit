/**************************************************************
 * Class: AppointmentSyncCleanupJob
 * Description: Batch Apex class to Sync Clean Up Job
 * Created Date: 13/06/2019
 * 
 * Version History
 * 
 * Version		Modified By 		Modified Date 		Description
 * 0.1			Santandar CRM		13/06/2019		
 * **********************************************************/	

global with sharing class AppointmentSyncCleanupJob implements Database.Batchable<sObject> {

/*********************************************************
* Method: start
* Description:Query the Appointment__c for IsNeworUpdatedByExternalProvider__c = FALSE records
* Parameter:Database.BatchableContext BC
* Return:	Database.getQueryLocator
* *****************************************************/
    
global Database.querylocator start(Database.BatchableContext BC){
        
        String query = 'select Id, IsNeworUpdatedByExternalProvider__c from Appointment__c where IsNeworUpdatedByExternalProvider__c = FALSE';
        return Database.getQueryLocator(query);
    }
    
    /*********************************************************
* Method:execute
* Description:Delete the Records
* Parameter:List<sObject> scope
* Return:
* *****************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){

	   try{
            if(scope != null){
                delete scope;
            } 
        }
        catch (Exception exc) {ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CalloutAttemptController','secureCallout', exc, 'ERROR');}         
    }
    
/*********************************************************
* Method:finish
* Description:Operations to be performed after batch class is executed - Call other batch class
* Parameter:Database.BatchableContext BC
* Return:
* *****************************************************/
    global void finish(Database.BatchableContext BC){

	AppointmentSyncReset callReset = new AppointmentSyncReset();
	Database.executeBatch(callReset);
        
    }
}