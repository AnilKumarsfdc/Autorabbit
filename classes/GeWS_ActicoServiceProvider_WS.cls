public abstract class GeWS_ActicoServiceProvider_WS extends GeWS_WebService_A{
    
    
   
    
    public override GeWS_WebService_A.CallOutResults interpretResponse(HttpResponse httpRes
                                                                      , HttpRequest httpReq) {
        //Standard location to interpret the response
        GeWS_WebService_A.CallOutResults callOutResult = new GeWS_WebService_A.CallOutResults();
        callOutResult.statusCode = httpRes.getStatusCode();
        callOutResult.status = httpRes.getStatus();
        callOutResult.Body = httpRes.getBody();
        callOutResult.hasErred = false; 
        //Populated Error Fields
        if (!String.valueOf(callOutResult.statusCode)
              .startsWith(GeWS_Constants.WS_HTTP_CODE_SUCCESS_START)) {
            populateErrorDetails(callOutResult,httpRes, httpReq );
            callOutResult.hasErred = true; 
        } 
        return callOutResult;
    }
    
    // Populate Error details
    
    private void populateErrorDetails(GeWS_WebService_A.CallOutResults callOutResult
                                      , HttpResponse httpRes
                                      , HttpRequest httpReq
                                      ){
        callOutResult.hasErred = true;
        String contentType = httpRes.getHeader(GeWS_Constants.CONTENT_TYPE);
        // get response Codes along with their descriptions
        if (contentType.contains(GeWS_Constants.HTTP_CONTENT_TYPE_JSON)) {
            callOutResult.errorMessage = null; // POPULATE WITH DETAILS
            String statusCode = String.valueOf(httpRes.getStatusCode());
            callOutResult.errorResponseMap = deserializeErrorResponse(
                                               httpRes.getBody()
                                               , String.valueOf(httpRes.getStatusCode())
                                               , httpReq);// POPULATE WITH DETAILS
            if(callOutResult.errorResponseMap.containsKey(GeWS_Constants.JSON_PARSE_CODE_TEXT) 
                && String.valueOf(callOutResult.errorResponseMap.get(GeWS_Constants.JSON_PARSE_CODE_TEXT)).equals(statusCode)) { 
                    callOutResult.errorMessage = statusCode+': '+callOutResult.errorResponseMap.get(GeWS_Constants.JSON_PARSE_ERROR_TEXT);
            }
        }      
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