public with sharing class CharityDataRefreshCallout {
    public static void execute(List<Account> accountList) {
        List<DueDilBatchUpdateRequestWrapper.CompanyMatchCriteriaWrapper> compMatchCriteriaList = new List<DueDilBatchUpdateRequestWrapper.CompanyMatchCriteriaWrapper>();      
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
                
        HttpResponse response = new HttpResponse();
        
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();

        try{
            // process each batch of records       
            for (Account account : accountList) {    
                compMatchCriteriaList.add(new DueDilBatchUpdateRequestWrapper.CompanyMatchCriteriaWrapper(account.CharityId__c,account.CharityCountryCode__c));
            }

            DueDilBatchUpdateRequestWrapper requestWrapper = new DueDilBatchUpdateRequestWrapper(compMatchCriteriaList, true, 'Charity','');
            System.Debug('JSON.serialize(requestWrapper) >>>>'+JSON.serialize(requestWrapper));
            String calloutRequestBody = JSON.serialize(requestWrapper);
            String calloutRequestURL = 'callout:'+entitySearchSettings.NamedCredentialsAPIName__c  + entitySearchSettings.BulkCompanyUpdateEndpointPath__c;

            DueDilEntitySearchServiceImpl  dueDilEntitySrch = new DueDilEntitySearchServiceImpl();
            String accessToken = dueDilEntitySrch.getAccessToken();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(calloutRequestURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(calloutRequestBody);
            request.setHeader('authorization', 'Bearer '+accessToken);

            System.Debug('Limit.getCallouts() >>>>'+Limits.getCallouts());
            System.Debug('Limits.getLimitCallouts() >>>>'+Limits.getLimitCallouts());

            System.Debug('Limit.getHeapSize() >>>>'+Limits.getHeapSize());
            System.Debug('Limits.getLimitHeapSize() >>>>'+Limits.getLimitHeapSize());

            response = CalloutAttemptController.secureCallout(request,entitySearchSettings);
            
                    
            System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode()); 
            System.debug('-------------response.getBody()-----------'+response.getBody()); 
        }
        catch(Exception exc){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CharityDataRefreshCallout','execute', exc.getMessage(), 'ERROR');
        }

    }
}