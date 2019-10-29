public abstract class GeWS_SpringCMServiceProvider_WS extends GeWS_WebService_A{
    
    
   
    
    public override GeWS_WebService_A.CallOutResults interpretResponse(HttpResponse httpRes
                                                                      , HttpRequest httpReq) {
        //Standard location to interpret the response
        GeWS_WebService_A.CallOutResults callOutResult = new GeWS_WebService_A.CallOutResults();
        callOutResult.statusCode = httpRes.getStatusCode();
        callOutResult.status = httpRes.getStatus();
        callOutResult.blobBody = httpRes.getBodyAsBlob();
        callOutResult.hasErred = false; 
        //Populated Error Fields
        if (!String.valueOf(callOutResult.statusCode)
              .startsWith(GeWS_Constants.WS_HTTP_CODE_SUCCESS_START)) {
            callOutResult.hasErred = true; 
        } 
        return callOutResult;
    }
    
    
    /*******************************************************************
    * @description interpret the error response   
    * @Param String
    * @Param String
    * @Param HTTPRequest     
    * @return Map<String, Object>
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public override Map<String, Object> deserializeErrorResponse(String responseString
                                                                 , String statusCode
                                                                 , HTTPRequest req) {       
        Map<String, Object> callOutErrorResponseMap = 
                    (Map<String, Object>)System.JSON.deserializeUntyped(responseString);
        return callOutErrorResponseMap;     
    }
}