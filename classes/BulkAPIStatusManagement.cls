public with sharing class BulkAPIStatusManagement {

    public class BulkJobCompletionRequesBody{
        public string Record_Id;
        public BulkJobCompletionRequesBody(String Record_Id_Arg){
            this.Record_Id = Record_Id_Arg;
        }
    }

    public static Id createBulkJobLogRecord(Boolean isRequestForSingleRecord){
        BulkAPITrackingLog__c bulkJobLog = new BulkAPITrackingLog__c( Status__c = 'Started', JobIdentifierTimestamp__c = String.valueOf(System.Now()), IsSingleEntityRefreshRequest__c=isRequestForSingleRecord);
        insert bulkJobLog;

        return bulkJobLog.Id;
    }

    public static void updateBulkJobLogToSent(Id recId , String status){
        BulkAPITrackingLog__c bulkJobLog = [Select Id, Status__c from BulkAPITrackingLog__c where Id = :recId];
        bulkJobLog.Status__c = status;
        update bulkJobLog;

        System.debug('bulkJobLog >>>>'+bulkJobLog);
    }

    public static void bulkJobCompletionCallout(String calloutRequestBody, Id recId, String entityType){
        try{
            EntitySearchSettings__mdt entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();     
            String calloutRequestURL = 'callout:'+entitySearchSettings.NamedCredentialsAPIName__c  + entitySearchSettings.BulkCompanyUpdateEndpointPath__c;        
            
            
            DueDilEntitySearchServiceImpl  dueDilEntitySrch = new DueDilEntitySearchServiceImpl();
            String accessToken = dueDilEntitySrch.getAccessToken();

            HttpRequest request = new HttpRequest();
            request.setEndpoint(calloutRequestURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(calloutRequestBody);
            request.setHeader('authorization', 'Bearer '+accessToken);

            System.debug('request.getBody() >>>>'+request.getBody());
            
            HTTPResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);
            
            if(response.getStatusCode() == 200){
                if(entityType.equalsIgnoreCase('Company')){BulkAPIStatusManagement.updateBulkJobLogToSent(recId,'Company Seed List Sent');}
                else if(entityType.equalsIgnoreCase('Charity')){
                 BulkAPIStatusManagement.updateBulkJobLogToSent(recId,'Charity Seed List Sent');
                }
            }
            else{
                throw new BulkAPICustomException.customExtendedException('Failed to Notify Sead List Completion. Error During Callout. Status Code: '+response.getStatusCode()+' Error Description: '+response.getStatus());   
            }
        }
        Catch(Exception exc){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('BulkAPIStatusManagement','bulkJobCompletionCallout', exc.getMessage(), 'ERROR');
        }
    }
}