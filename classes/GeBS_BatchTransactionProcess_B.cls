public with sharing class GeBS_BatchTransactionProcess_B implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    public List<GeDM_Batch_Transaction__c> batchTransactionUpdateList = new List<GeDM_Batch_Transaction__c>();
    public Map<String, GeWS_ActicoUtils.StatusUpdateBatchWrapper> responseAttributesMap = new Map<String, GeWS_ActicoUtils.StatusUpdateBatchWrapper>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        string batchTransactionQuery = GeWS_ActicoUtils.composeQueryFields('GeDM_Batch_Transaction__c')+' where Is_Batch_Successful__c = false'; 
        
        return Database.getQueryLocator(batchTransactionQuery);
        
    }
    
    public void execute(Database.BatchableContext bc, List<GeDM_Batch_Transaction__c> scope){
        for(GeDM_Batch_Transaction__c bt : scope){
            responseAttributesMap.put(bt.Parent_Record_Id__c,GeWS_Rating_Callout_WS.processStatusUpdateCallout(bt));
            batchTransactionUpdateList.add(bt);
        }
        
    }
    
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new GeBS_BatchTransactionProcess_B(),90);
    }
    
    public void finish(Database.BatchableContext bc){
        
        GeWS_ActicoUtils.processStatusUpdateBatchResponses(responseAttributesMap);
        
        update batchTransactionUpdateList;
    }

}