public with sharing class CalloutAttemptController {
  
    public static HttpResponse secureCallout(HTTPRequest request, EntitySearchSettings__mdt entitySearchSetting){
        Integer counter = 0;
        Boolean integrationError = false;
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        String deserializedResponseMessages = '';
        ExceptionHandlingSettings__c exceptionHandlingCS = ExceptionHandlingSettings__c.getOrgDefaults();
        try{
            
            do{
                try{
                    ++counter;
                    System.debug('request >>>>'+request);
                    response = http.send(request);
                    System.debug('response.getBody() >>>>'+response.getBody());
                    Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    System.debug('deserializedResponse >>>>'+deserializedResponse);

                    Map<String, Object> metaDeserialized = (Map<String, Object>)deserializedResponse.get('meta');
                    //String serializedCode = String.valueOf(metaDeserialized.get('code'));
                    //System.debug('serializedCode >>>>'+serializedCode);                    

                    //if(!serializedCode.equals('000000')){
                    if(response.getStatusCode() != 200){
                        integrationError = true;
                        List<Object> messageList = (List<Object>)metaDeserialized.get('messages');
                        deserializedResponseMessages = JSON.serialize(messageList);                        
                    }
                    
                    System.debug('Attempt -->'+counter);
                }catch(Exception ex){
                    integrationError=true;
                }
            }while ( integrationError && counter < entitySearchSetting.CalloutAttempts__c);
            if(integrationError){
                System.debug('An Error during Callout has occured');
                if(response.getStatusCode() == 401){
                    System.debug('A 401 Error during Callout has occured');
                    deserializedResponseMessages = 'Authorisation Error during Hierarchy Refresh Batch Callout has occured'; 
                    if(!exceptionHandlingCS.WSO2AuthenticationFailureFlag__c){
                        ExceptionLogService.sendAuthErrorNotifMail(deserializedResponseMessages);
                    }

                    exceptionHandlingCS.WSO2AuthenticationFailureFlag__c = true;
                    update exceptionHandlingCS;
}
                
                throw new BulkAPICustomException.customExtendedException(deserializedResponseMessages);                 
            }
        } catch(Exception exc){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('CalloutAttemptController','secureCallout', deserializedResponseMessages, 'ERROR'); 
            throw new BulkAPICustomException.customExtendedException(deserializedResponseMessages); 
        }
        return response;
    }

}