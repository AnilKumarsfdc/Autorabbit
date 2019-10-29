global class CharityDataRefresh implements 
    Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {  
    global Id statusRecord;
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    global CharityDataRefresh(Id recordIdReceived){
        this.statusRecord = recordIdReceived;
    }
    
    global CharityDataRefresh(){
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {  
        return AccountService.getChartiesForRefresh();
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        recordsProcessed += scope.size();
        try{
            CharityDataRefreshCallout.execute(scope);
        }
        catch(Exception exc){ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CharityDataRefresh','execute', exc, 'ERROR'); 
        }
    }    

    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new CharityDataRefresh(),2000);
    }

    global void finish(Database.BatchableContext bc){       
        System.debug('statusRecord >>>>'+statusRecord);
        //BulkAPIStatusManagement.BulkJobCompletionRequesBody requestWrapper = new BulkAPIStatusManagement.BulkJobCompletionRequesBody(statusRecord);
            
        DueDilBatchUpdateRequestWrapper requestWrapper = new DueDilBatchUpdateRequestWrapper(null, true, 'Charity',statusRecord);

        String calloutRequestBody = JSON.serialize(requestWrapper);
        
        System.debug('calloutRequestBody >>>>'+calloutRequestBody);

        BulkAPIStatusManagement.bulkJobCompletionCallout(calloutRequestBody,statusRecord, 'Charity');
        
    }    


    
}