/**************************************************************
* Class: CompanyFilingSyncReset
* Description: Batch Apex class to Clean Up and Reset Sync Job
* Created Date: 13/06/2019
* 
* Version History
* 
* Version		Modified By 		Modified Date 		Description
* 0.1			Santandar CRM		13/06/2019		
* **********************************************************/	
global with sharing class CompanyFilingSyncReset implements Database.Batchable<sObject>{
    
    /*********************************************************
* Method: start
* Description:Query the CompanyFilings__c for IsNeworUpdatedByExternalProvider__c = TRUE records
* Parameter:Database.BatchableContext BC
* Return:Database.getQueryLocator
* *****************************************************/
    global Database.querylocator start(Database.BatchableContext BC){
        
        String query = 'select Id,IsNeworUpdatedByExternalProvider__c from CompanyFilings__c where IsNeworUpdatedByExternalProvider__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    /*********************************************************
* Method:execute
* Description:Update the Records
* Parameter:List<sObject> scope
* Return:
* *****************************************************/
    global void execute(Database.BatchableContext BC, List<CompanyFilings__c> scope){
        
        
        try{
            if(scope != null){
                for(CompanyFilings__c cf : scope)
                {
                    cf.IsNeworUpdatedByExternalProvider__c = FALSE;
                }
                update scope;
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
        
        CompanyChargesSyncCleanup callclean = new CompanyChargesSyncCleanup();
        database.executebatch(callclean);
        
    }
}