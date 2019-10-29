public class GeWS_ActicoService_WS extends GeWS_ActicoServiceProvider_WS{
    GeWS_WebService_A.CallOutResults callOutResult;
    Map<String, String> parameters;
    Map<String, String> urlReplacements;
    String endpoint;
    String serviceName;
    
    
    public String SendFinancialData(String requestBody){
        
        serviceName = 'FinancialServiceAPI';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
        endpoint = integrationSettings.get(serviceName).GeWS_Endpoint__c;
        endpoint = populateEndPoint(endpoint,urlReplacements, parameters);
        endpoint = endpoint;
        parameters.clear();
        parameters.put('entity-Id','YRC');
        parameters.put('CreateLog','false');
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_POST
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                              , requestBody
                                              , true
                                              , parameters);  
        
        return callOutResult.Body;
        
    }
    
    public String SendRatingsData(String requestBody){
        
        serviceName = 'RatingServiceAPI';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
        endpoint = integrationSettings.get(serviceName).GeWS_Endpoint__c;
        endpoint = populateEndPoint(endpoint,urlReplacements, parameters);
        endpoint = endpoint;
        parameters.clear();
        parameters.put('entity-Id','YRC');
        parameters.put('CreateLog','True');
        
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_POST
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                              , requestBody
                                              , true
                                              , parameters);  
        
        
        return callOutResult.Body;
        
    }
    
    public String SendStatusUpdateData(String requestBody){
        
        serviceName = 'ApprovalServiceAPI';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
        endpoint = integrationSettings.get(serviceName).GeWS_Endpoint__c;
        endpoint = populateEndPoint(endpoint,urlReplacements, parameters);
        endpoint = endpoint;
        parameters.clear();
        parameters.put('entity-Id','YRC');
        parameters.put('CreateLog','True');
        
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_POST
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                              , requestBody
                                              , true
                                              , parameters);  
        
        
        return callOutResult.Body;
        
        
    }
}