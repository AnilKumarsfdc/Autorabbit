public class GeWS_NuxeoService_WS extends GeWS_NuxeoServiceProvider_WS{
    GeWS_WebService_A.CallOutResults callOutResult;
    Map<String, String> parameters;
    Map<String, String> urlReplacements;
    String endpoint;
    String serviceName;
    
    
    public blob getSpringCMDocumentById(string documentId){
        
        //string responseStr;
        //Setup Required Parameters
        serviceName = 'SpringCMDownloadAPI';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
        
        
        endpoint = integrationSettings.get(serviceName).GeWS_Endpoint__c;
        endpoint = populateEndPoint(endpoint,urlReplacements, parameters);
        endpoint = endpoint+'/'+documentId;
        
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_GET
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_URL
                                              , true
                                              , false);  
        
        system.debug('@@callOutResult.blobBody=='+callOutResult.blobBody);
        return callOutResult.blobBody;
        
    }
}