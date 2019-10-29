public abstract with sharing class GeWS_WebService_A {
    
    public Map<String, GeWS_WebService_Integration_Settings__c> integrationSettings;
    public enum GeWS_HTTPMethod { POST,GET,PATCH,PUT }


    public GeWS_WebService_A.CallOutResults callOutResult;
    public Map<String, String> parameters;
    public Map<String, String> urlReplacements;
    public String endpoint;
    public static List<Exception_Log__c> ListexceptionObj = new List<Exception_Log__c>();

    /******************* Declaration of variables *********************/
      
    public String lastEndpointCalled;
    
    protected Integer timeout;       
    protected String authorizationHeader;
    protected String userAgent;
   

    /******************* Constructor             *********************/    
    public GeWS_WebService_A() {
        integrationSettings = GeWS_WebService_Integration_Settings__c.getAll(); 
        defaultVariables();
    }

    /*******************************************************************
    * @description Defaults the variables                        
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private Void defaultVariables(){
        lastEndpointCalled = null;
        timeout = 0;
        authorizationHeader = null;
        userAgent = null; 
             
    }

    private void initaliseForWebServiceCall(){
        //Setup Required Parameters
        endpoint = '';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
    }

    public void initaliseForWebServiceCall(String wsType){
        initaliseForWebServiceCall();
        endpoint = integrationSettings.get(wsType).GeWS_Endpoint__c;     
    }
    /*******************************************************************
        Purpose: Utility method for building an endpoint to be called by a web-service
        Parameters: URL, Record ID, web-service function and a map of parameters to be appended
        Returns: String endpoint for the web-service call
        Throws [Exceptions]: [optional]
    ********************************************************************/      
    protected virtual String populateEndPoint(String url
                                            , Map<String, String> urlReplacements
                                            , Map<String, String> parameters) {
        String finalEndPoint = url;
        
        // Determine if endpoint already has a trailing slash - if not, add one
        if (!finalEndPoint.endsWith('/')) {
            finalEndPoint += '/';
        }
        //replace any required URI Replacements
        //eg www.example.com/{UID}/test  to be www.example.com/123423423423/test
        if(urlReplacements!= null){
            for(String aKey : urlReplacements.keySet()){
                finalEndPoint = finalEndPoint.replace(aKey, urlReplacements.get(aKey));
            }
        }
        //These are the parameters at the end of the URI 
        //eg www.example.com?Take=value&Skip=value
        if(parameters != null){
            finalEndPoint = addParameters(finalEndPoint,parameters);
        }
        
        return finalEndPoint;
    }

    /*******************************************************************
    * @description Adds Parameters onto the URL                       
    * @return Strin
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private String addParameters(String endPoint, Map<String, String> parameters){

        // If the URL has a trailing slash, remove it before adding the parameters
        if (endPoint.endsWith('/')) {
            endPoint = endPoint.substring(0, endPoint.length() -1);
        }

        // Add parameters to the end of the URL
        if (parameters != null) {
            endPoint += '?';
            for (String arg : parameters.keySet()) {
                if (endPoint.endsWith('?')) {
                    endPoint += arg + '=' + parameters.get(arg);
                } else {
                    endPoint += '&' + arg + '=' + parameters.get(arg);
                }       
            }
        } 
        // If the URL has a trailing question mark, remove it
        if (endPoint.endsWith('?')) {
            endPoint = endPoint.substring(0, endPoint.length() -1);
        }  
        return endPoint;
    }
    
    /*******************************************************************
    * @description Calls out to Web Service and sends returns a response
                    This is used where a Object of the body has been created                      
    * @return CallOutResults
    * @Throws [Exceptions]: WSEXCEPTION                                                 
    ********************************************************************/
    public virtual CallOutResults callOutToWebService (String method
                                                    , String endpoint
                                                    , String wS_IntegrationSettingName
                                                    , String contentType
                                                    , Map<String, Object> requestBody
                                                    , Boolean retryIfBusy
                                                    , map<string,string> additionalParams){
        return callOutToWebService(method
                                , endpoint
                                , wS_IntegrationSettingName
                                , contentType
                                , String.valueOf(JSON.serialize(requestBody))
                                , retryIfBusy
                                , additionalParams);
    }

    /*******************************************************************
    * @description Calls out to Web Service and sends returns a response
                    This is used where a Object of the body has been created                      
    * @return CallOutResults
    * @Throws [Exceptions]: WSEXCEPTION                                                 
    ********************************************************************/
    public virtual CallOutResults callOutToWebService (String method
                                                    , String endpoint
                                                    , String wS_IntegrationSettingName
                                                    , String contentType
                                                    , Boolean retryIfBusy
                                                    , map<string,string> additionalParams
                                                    ){
        return callOutToWebService(method
                                , endpoint
                                , wS_IntegrationSettingName
                                , contentType
                                , ''
                                , retryIfBusy
                                , additionalParams);
    }
   
    /*******************************************************************
    * @description Calls out to Web Service and sends returns a response
                    This is used where a Object of the body has been created                      
    * @return CallOutResults
    * @Throws [Exceptions]: WSEXCEPTION                                                 
    ********************************************************************/
    public virtual CallOutResults callOutToWebService (String method
                                                    , String endpoint
                                                    , String wS_IntegrationSettingName
                                                    , String contentType
                                                    , String requestBody
                                                    , Boolean retryIfBusy
                                                    , map<string,string> additionalParams
                                                    ){

        // Create a new instance of the results object
        CallOutResults results = new CallOutResults();
        
        // Attempt the callout
        results = makeWSCall(method
                            , endpoint
                            , wS_IntegrationSettingName
                            , contentType
                            , requestBody
                            , retryIfBusy
                            , additionalParams);
        return results;
    }

    /*******************************************************************
    * @description Prepares the request for the web-service callout and 
                    performs it (retries if service is busy and is specified)                      
    * @return CallOutResults
    * @Throws [Exceptions]: WSEXCEPTION                                                 
    ********************************************************************/
    protected virtual CallOutResults makeWSCall(String method
                                                , String endpoint
                                                , String wS_IntegrationSettingName
                                                , String contentType
                                                , String bodyOfMessage
                                                , Boolean retryIfBusy
                                                , map<string,string> additionalParams
                                                ) {  

        // Set the values to be used in the request
        HttpRequest req = setHTTPRequestValues(method
                                                , endpoint
                                                , wS_IntegrationSettingName
                                                , contentType
                                                , bodyOfMessage);

        string createLogs;
        if(additionalParams != null || !additionalParams.isEmpty()){
            if(additionalParams.containsKey('entity-Id')){
                req.setHeader('entity-Id',additionalParams.get('entity-Id'));     
            }
            
            createLogs = additionalParams.get('CreateLog');
        }
        System.debug('This is the request in updated method== ' + req); 

        // Create an instance of a response
        HTTPResponse response;
        
        // The for loop is used to call again if the service is busy (returns a 429 error)
        for (Integer i = 0; i <= 1; i++) {
            // Make the callout and populate the response object
            response = sendRequest(req,boolean.valueOf(createLogs));  
                     
            // If no response was returned the return this to the calling method            
            if (response == null) {
                return null;
            // Else if the status is NOT a  then break (do not attempt a second time)
            } else if (!retryIfBusy || String.valueOf(response.getStatusCode()) != '429') { 
                break;
            }
        }       
        
        lastEndpointCalled = endpoint;
        // Interpret the response and return to the calling system                 
        return interpretResponse(response, req);                                                         
        
    }
    
    /*******************************************************************
    * @description Sends a request and returns the response 
    * @Param  HTTPRequest
    * @return HTTPResponse
    * @Throws [Exceptions]: WSEXCEPTION                                                 
    ********************************************************************/   
    protected virtual HTTPResponse sendRequest(HTTPRequest req, boolean createLog) {
       
        
        system.debug('@@isBatch==='+system.isBatch());
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        try {
            response = http.send(req); 
        } catch (Exception e) { 
            string msg = e.getMessage()+' At line no= ' +e.getLineNumber();
            this.createLog('GeWS_WebService_A', 'SendRequest', msg ,createLog, 'ERROR');
        }finally {
            // Insert the Log file into exception object...
            if(!system.isBatch()){
                if(string.isNotBlank(req.getBody())){
                    ListexceptionObj.add(this.getExceptionLog('GeWS_WebService_A', 'SendRequest','Request Body Sent:\n\n'+req.getBody()+'\n\n\n\nResponse Received:\n\n'+response.getBody(), 'INFO'));
                }
                
                if(createLog){
                    insert ListexceptionObj;
                }
                    
            }
            
        }
          
        return response;
    }  

    /*******************************************************************
    * @description Sets Method for the Callout
    * @Param  String
    * @Param  HttpRequest
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/      
    protected virtual Void setMethodForCallout(String method, HttpRequest req){
        //Populates the Method of the API request
        if (method == null || method == '') {
            //<<TO DO ADD EXCEPTION FRAMEWORK>>
        } else if (method.tolowerCase() == GeWS_Constants.WS_METHOD_PATCH) {
            req.setMethod(GeWS_Constants.WS_METHOD_POST);
            req.setHeader(GeWS_Constants.WS_X_HTTP_METHOD_OVERRIDE_HEADER, method);
        } else {
            req.setMethod(method);
        }
    }

    /*******************************************************************
    * @description Sets the HTTP Request Values
    * @Param  String
    * @Param  String
    * @Param  String
    * @Param  HttpRequest
    * @Throws [Exceptions]: <<TO DO>>                                               
    ********************************************************************/
    protected virtual HttpRequest setHTTPRequestValues(String method
                                                    , String endpoint
                                                    , String contentType) {
        // Create a new instance of the HTTP Request
        HttpRequest req = new HttpRequest();

        // Populate the mandatory properties for the HTTP Request
        if (endpoint != null && endpoint != '') {        
            req.setEndpoint(endpoint);
        }

        //Set the HTTP Method for Callout
        setMethodForCallout(method,req);
        //Set the Content Type
        if (contentType != null && contentType != '') {
            req.setHeader(GeWS_Constants.CONTENT_TYPE, contentType);
        }
        return req;
    }

    /*******************************************************************
    * @description Sets the HTTP Request Values
    * @Param  String
    * @Param  String
    * @Param  String
    * @Param  String
    * @Param  String
    * @Param  HttpRequest
    * @Throws [Exceptions]: <<TO DO>>                                               
    ********************************************************************/     
    protected virtual HttpRequest setHTTPRequestValues(String method
                                                    , String endpoint
                                                    , String wS_IntegrationSettingName
                                                    , String contentType
                                                    , String bodyOfRequest) {
        //sets the Request Values
        HttpRequest req = setHTTPRequestValues(method,endpoint,contentType);

        //Set Header Values
        req = setHeaderValues(req, wS_IntegrationSettingName);
        
        // If a body for the request was supplied 
        if (bodyOfRequest != null && bodyOfRequest != '') {
            req.setBody(bodyOfRequest);
        }
        
        return req;
    }
   
   /*******************************************************************
    * @description Adds the Timeout to the request 
    * @Param  HttpRequest
    * @Param  String
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/  
    protected virtual HttpRequest addTimeOut(HttpRequest request, String wS_IntegrationSettingName){
        Integer apiTimeout 
                    = Integer.valueof(
                        GeWS_WebService_Integration_Settings__c.getValues(wS_IntegrationSettingName).GeWS_Timeout__c);

        if(apiTimeout != null){
            request.setTimeout(apiTimeout);
        }
        return request;                 
    }

    /*******************************************************************
    * @description Sets Method for the Callout
    * @Param  String
    * @Param  HttpRequest
    * @return HTTPResponse
    * @Throws [Exceptions]: <<TO DO>>                                                
    ********************************************************************/  
    protected virtual HttpRequest addCredentials(HttpRequest request, String wS_IntegrationSettingName){
        //Get the Identifer for the Credentials used
        
        String credentialIdentifier 
                    = GeWS_WebService_Integration_Settings__c.getValues(wS_IntegrationSettingName).GeWS_IntegrationCredentialIdentifier__c;
        
        system.debug('In credentialIdentifier =='+credentialIdentifier);
        if(credentialIdentifier != null){
            //Get an instance of the credentials to use for this callout
            GeWs_SecuritCredential_DAO secCredDAC = new GeWs_SecuritCredential_DAO();
            GeWS_Security_Credential__c secCred = secCredDAC.getSecurityCredentialByIdentifier(credentialIdentifier);
            //determine the approrpaite authentication to use
            if(secCred != null){
                //Set userAgent for Requests
                //request.setHeader(GeWS_Constants.WS_USER_AGENT, secCred.GeWS_User_Agent__c);
                if(secCred.GeWS_Credential_Type__c.equals(GeWS_Constants.WS_BEARER_TOKEN)){
                    return setBearerOAuth(request, secCred);
                }                
                if(secCred.GeWS_Credential_Type__c.equals(GeWS_Constants.WS_JWT_TOKEN)){
                    return setJWTTokenOAuth(request, secCred);
                } 
            }
        }
        
        return request;                 
    }
    
     
     
     
     
     
     //*******************************************
     
     protected virtual HttpRequest setBearerOAuth(HttpRequest request
                                            , GeWS_Security_Credential__c credentials) {

        String accessToken = null;
        
        //Set the elements for the callout
        HttpRequest accessRequest = setHTTPRequestValues(GeWS_Constants.WS_METHOD_POST
                                                        , oAuthEndPoint(credentials)
                                                        , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                                        );
      
        if(credentials.GeWS_Credential_Identifier__c == 'SpringCMAPI'){
            String clientId = credentials.GeWS_API_Key__c;
            String secrete = credentials.GeWS_API_Secret__c;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('client_id', clientId);
            gen.writeStringField('client_secret', secrete);
            gen.writeEndObject();
            string bodyOfRequest = gen.getAsString();
            
            accessRequest.SetBody(bodyOfRequest);
        }
        else{
            system.debug('this is Actico Service--');
            String ConsumerKey = credentials.GeWS_API_Key__c;
            String ConsumerSecret = credentials.GeWS_API_Secret__c;
            accessRequest.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(ConsumerKey+':'+ConsumerSecret)));           
            accessRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        }
        system.debug('accessRequest =='+accessRequest.getHeader('Content-Type'));
        
        HTTPResponse accessResponse = this.sendRequest(accessRequest, false);
        system.debug('accessResponse=='+accessResponse.getBody());
        String responseBody = accessResponse.getBody();

        accessToken = String.valueOf(
                        ((Map<String, Object>) JSON.deserializeUntyped(responseBody))
                                .get(GeWS_Constants.WS_OAUTH_ACCESS_TOKEN));
        
        System.debug('accessToken =='+accessToken);
        //Set the Header
        request.setHeader(GeWS_Constants.WS_AUTHORIZATION_HEADER, GeWS_Constants.WS_BEARER+accessToken);       
        return request;
    }
    
    
    //Nuxeo 
     protected virtual HttpRequest setJWTTokenOAuth(HttpRequest request
                                            , GeWS_Security_Credential__c credentials) {

        String jwtToken = null;
        
        //Set the elements for the callout
        HttpRequest accessRequest = setHTTPRequestValues(GeWS_Constants.WS_METHOD_POST
                                                        , oAuthEndPoint(credentials)
                                                        , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                                        );
      
        if(credentials.GeWS_Credential_Identifier__c == 'NuxeoAPI'){
            String clientId = credentials.GeWS_API_Key__c;
            String secrete = credentials.GeWS_API_Secret__c;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            
            // body POSTMAN 
            gen.writeStringField('subject', '0f8aface-181a-4685-9c9a-fd279022918c'); // X-IBM_Client-Id   client_id
            gen.writeStringField('audience', 'document-vault'); // X-IBM_Client-Secret  client_secret
            gen.writeStringField('miscInformation', 'F000000001'); // X-IBM_Client-Secret  client_secret
            gen.writeStringField('userType', 'Client-ID or ResourceOwner'); // X-IBM_Client-Secret  client_secret
            gen.writeEndObject();
            string bodyOfRequest = gen.getAsString();
            
            accessRequest.SetBody(bodyOfRequest);
            
            /// header code
            system.debug('this is Nuxeo Service--');
            String ConsumerKey = credentials.GeWS_API_Key__c;
            String ConsumerSecret = credentials.GeWS_API_Secret__c;
           // accessRequest.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(ConsumerKey+':'+ConsumerSecret)));           
            accessRequest.setHeader('X-IBM_Client-Id', clientId); // X-IBM_Client-Id   client_id
            accessRequest.setHeader('X-IBM_Client-Secret', secrete); // X-IBM_Client-Secret  client_secret
            accessRequest.setHeader('Accept', 'application/json'); // X-IBM_Client-Secret  client_secret
            accessRequest.setHeader('Content-Type', 'application/json'); // X-IBM_Client-Secret  client_secret      
            
        }

        system.debug('accessRequest =='+accessRequest.getHeader('Content-Type'));
        
        HTTPResponse accessResponse = this.sendRequest(accessRequest, false);
        system.debug('accessResponse=='+accessResponse.getBody());
        String responseBody = accessResponse.getBody();

        jwtToken = String.valueOf(
                        ((Map<String, Object>) JSON.deserializeUntyped(responseBody))
                                .get(GeWS_Constants.WS_OAUTH_JWT_TOKEN));
        
        System.debug('jwtToken =='+jwtToken);
        //Set the Header
        request.setHeader(GeWS_Constants.WS_AUTHORIZATION_HEADER, GeWS_Constants.WS_BEARER+jwtToken);       
        return request;
    }
    
   /*******************************************************************
    * @description Sets the Headers for the HTTP Request
    * @Param  HttpRequest
    * @Param  String
    * @return HttpRequest
    * @Throws [Exceptions]: <<TO DO>>                                                
    ********************************************************************/   
    protected virtual HttpRequest setHeaderValues (HttpRequest request, String wS_IntegrationSettingName) {
        request = addTimeOut(request,wS_IntegrationSettingName);
        request = addCredentials(request,wS_IntegrationSettingName);
        return request;
    }

    
    
    /*******************************************************************
        Purpose: Generates the OAuth2 endpoint
        Parameters: credentials - creds to use when building the arguments  
        Returns: String - URL with any associated parameters and values
        Throws [Exceptions]: NONE
    ********************************************************************/ 
    protected virtual String oAuthEndPoint(GeWS_Security_Credential__c credentials){
        String oAuth2EndPoint = credentials.GeWS_Authentication_Endpoint__c;

        Map<String, String> urlParameters;
        if(credentials.GeWS_Grant_Type__c == GeWS_Constants.HTTP_GRANT_TYPE_PASSWORD){
            //urlParameters = oAuthGrantTypePassword(credentials);
        }
        else if(credentials.GeWS_Grant_Type__c == GeWS_Constants.HTTP_GRANT_TYPE_CLIENT_CREDENTIALS){ 
            urlParameters = oAuthGrantTypeClientCredentials(credentials);
        }
        
        if(urlParameters != null && !urlParameters.isEmpty()){
            oAuth2EndPoint = addParameters(oAuth2EndPoint, urlParameters);
        }

        return oAuth2EndPoint;
    }

  
   
     /*******************************************************************
        Purpose: Adds parameters to the oAuth call for the grant type of
                 ClientCredentials
        Parameters: credentials - creds to use when building the arguments  
        Returns: Map<String, String> - Map of URL parameters and values
        Throws [Exceptions]: NONE
        Added By : 
    ********************************************************************/ 
    protected virtual Map<String, String> oAuthGrantTypeClientCredentials(GeWS_Security_Credential__c credentials){
        Map<String, String> urlParameters = new Map<String, String>();
        urlParameters.put(GeWS_Constants.GRANT_TYPE,GeWS_Constants.HTTP_GRANT_TYPE_CLIENT_CREDENTIALS);
        if(credentials != null){
            //urlParameters.put(GeWS_Constants.HTTP_PARAMETER_CLIENT_ID, credentials.GeWS_API_Key__c);
            //urlParameters.put(GeWS_Constants.HTTP_PARAMETER_CLIENT_SECRET, credentials.GeWS_API_Secret__c);
        }
        return urlParameters;   
    }

    /*******************************************************************
        Purpose: Deserializes a JSON response
        Parameters: String 
        Returns: Void
        Throws [Exceptions]: [optional]
    ********************************************************************/   
    protected abstract Map<String, Object> deserializeErrorResponse(String responseString
                                                                    , String statusCode
                                                                    , HTTPRequest req);

    /*******************************************************************
    * @description Adbstract class to be overriden, used to interpret 
                   response from WS call
    * @Param  HTTPRequest
    * @Param  HTTPRequest
    * @return HTTPResponse
    * @Throws [Exceptions]: WSEXCEPTION                                                 
    ********************************************************************/         
    protected abstract CallOutResults interpretResponse(HTTPResponse response
                                                      , HTTPRequest request);    
    
    /*******************************************************************
        Purpose: Inner class for holding results of the callout 
    ********************************************************************/     
    public class CallOutResults {
        
        public Integer statusCode;
        public String status;
        public String body;
        public blob blobBody;
        public Boolean hasErred;
        public String errorMessage;
        public Map<String, Object> errorResponseMap; 
        public String errorCode;
        public String requestBody;
        public String requestMethod;
   
    }
    
    
    public Exception_Log__c getExceptionLog(string className, String MethodName, string msg,string errType){
        Exception_Log__c exceptionObj = new Exception_Log__c();
        exceptionObj.Class__c = className;
        exceptionObj.Method__c = MethodName;
        exceptionObj.Message__c = msg;
        exceptionObj.Priority__c = errType;
        exceptionObj.Running_User__c = UserInfo.getUserName();
        return exceptionObj;
        
    }
    
    public void createLog(string className, String MethodName, string msg, boolean createLog, string errType){
        Exception_Log__c exceptionObj = new Exception_Log__c();
        exceptionObj.Class__c = className;
        exceptionObj.Method__c = MethodName;
        exceptionObj.Message__c = msg;
        exceptionObj.Priority__c = errType;
        exceptionObj.Running_User__c = UserInfo.getUserName();
        if(createLog && msg != ''){
            insert exceptionObj;
        }
    
    }
      
}