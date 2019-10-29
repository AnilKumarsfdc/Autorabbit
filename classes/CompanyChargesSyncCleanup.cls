/**************************************************************
 * Class: CompanyChargesSyncCleanup
 * Description: Batch Apex class to Clean Up Job
 * Created Date: 13/06/2019
 * 
 * Version History
 * 
 * Version		Modified By 		Modified Date 		Description
 * 0.1			Santandar CRM		13/06/2019		
 * **********************************************************/	
global with sharing class CompanyChargesSyncCleanup implements Database.Batchable<sObject>{


    
    /*********************************************************
     * Method: start
     * Description:Query the CompanyCharges__c for IsNeworUpdatedByExternalProvider__c = FALSE records
     * Parameter:Database.BatchableContext BC
     * Return:Database.getQueryLocator
     * *****************************************************/
global Database.querylocator start(Database.BatchableContext BC){
        
        String query = 'select Id,IsNeworUpdatedByExternalProvider__c from CompanyCharges__c where IsNeworUpdatedByExternalProvider__c = FALSE';
        return Database.getQueryLocator(query);
    }
    
    /*********************************************************
     * Method:execute
     * Description:Delete the Records
     * Parameter:List<sObject> scope
     * Return: List<sObject> scope
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

	CompanyChargesSyncReset callReset = new CompanyChargesSyncReset();
	database.executebatch(callReset);
        
    }
}