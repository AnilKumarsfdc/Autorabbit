/**************************************************************
 * Class: CharityClassifierSyncReset
 * Description: Batch Apex class to Sync Reset Job
 * Created Date: 13/06/2019
 * 
 * Version History
 * 
 * Version		Modified By 		Modified Date 		Description
 * 0.1			Santandar CRM		13/06/2019		
 * **********************************************************/	

global with sharing class CharityClassifierSyncReset implements Database.Batchable<sObject>  {

/*********************************************************
* Method: start
* Description: Query the CharityClassifier__c for IsNeworUpdatedByExternalProvider__c = TRUE records
* Parameter: Database.BatchableContext BC
* Return: Database.getQueryLocator
* *****************************************************/
    
    global Database.querylocator start(Database.BatchableContext BC){
        
        String query = 'select ID, IsNeworUpdatedByExternalProvider__c from CharityClassifier__c where IsNeworUpdatedByExternalProvider__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    /*********************************************************
* Method: execute
* Description: Update the Records
* Parameter: List<sObject> scope
* Return:
* *****************************************************/
    global void execute(Database.BatchableContext BC, List<CharityClassifier__c> scope){
        
        try{
            if(scope !=null){
                for(CharityClassifier__c cc : scope) 
                {
                    cc.IsNeworUpdatedByExternalProvider__c = FALSE;
                }
                update scope;
            }
        }
        catch (Exception exc) {ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CalloutAttemptController','secureCallout', exc, 'ERROR');}     
    }
    
    /*********************************************************
* Method: finish
* Description: NA
* Parameter: Database.BatchableContext BC
* Return:
* *****************************************************/
    global void finish(Database.BatchableContext BC){
        
        FCAAuthorisationSyncCleanup callCleanup = new FCAAuthorisationSyncCleanup();
        Database.executeBatch(callCleanup);
    }
}