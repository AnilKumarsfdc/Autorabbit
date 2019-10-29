global with sharing class CompanyHierarchyAndContactRefresh implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {  
    // instance member to retain state across transactions
    global Id statusRecord;
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {   
        statusRecord = BulkAPIStatusManagement.createBulkJobLogRecord(false);
        return AccountService.getCompaniesForRefresh();
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        recordsProcessed += scope.size();
        System.debug('recordsProcessed: '+ recordsProcessed);
        try{
            CompanyDataRefresh.execute(scope);
        }
        catch(Exception exc){ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CompanyHierarchyAndContactRefresh','execute', exc, 'ERROR'); 
        }
    }    

    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new CompanyHierarchyAndContactRefresh(),2000);
    }

    global void finish(Database.BatchableContext bc){       
        System.debug('triggering charity batch');
        
        DueDilBatchUpdateRequestWrapper requestWrapper = new DueDilBatchUpdateRequestWrapper(null, true, 'Company',statusRecord);

        String calloutRequestBody = JSON.serialize(requestWrapper);
        
        BulkAPIStatusManagement.bulkJobCompletionCallout(calloutRequestBody,statusRecord, 'Company');
        
        //Database.executeBatch(new CharityDataRefresh(statusRecord),2000);
        

    }    
    
}