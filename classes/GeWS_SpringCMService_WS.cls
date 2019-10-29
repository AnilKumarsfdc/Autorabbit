public class GeWS_SpringCMService_WS extends GeWS_SpringCMServiceProvider_WS{
    GeWS_WebService_A.CallOutResults callOutResult;
    Map<String, String> parameters;
    // Default Value for error log creation is flase, pass 'True' to create the log.
    Map<String, String> addParam = new Map<String, String>{'CreateLog'=>'False'};
    Map<String, String> urlReplacements;
    String endpoint;
    String serviceName;
    
    
    public blob getSpringCMDocumentById(string documentId){
        
        //string responseStr;
        //Setup Required Parameters
        serviceName = GeWS_Constants.SPRINGCM_DOWNLOAD_SERVICE;//'SpringCMDownloadAPI';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
        
        
        endpoint = integrationSettings.get(serviceName).GeWS_Endpoint__c;
        //endpoint = populateEndPoint(endpoint,urlReplacements, parameters);
        endpoint = endpoint+'/'+documentId;
        
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_GET
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_URL
                                              , true
                                              , addParam);  
        
        system.debug('@@callOutResult.blobBody=='+callOutResult.blobBody);
        return callOutResult.blobBody;
        
    }
}