public class NotificationHandler {
    public static void postNotification(List<LLC_BI__Loan__c> lstLoan) {
        // Get Custom Notification type id
        List<CustomNotificationType> lstNotifyType = [SELECT id,customNotifTypeName FROM CustomNotificationType LIMIT 1];

        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('inputs');
        jsGen.writeStartArray();
        
        for(LLC_BI__Loan__c objLoan : lstLoan) {
            jsGen.writeStartObject();
            // set Custom Notification type id
            jsGen.writeStringField('customNotifTypeId', (String)lstNotifyType[0].get('Id'));
            jsGen.writeFieldName('recipientIds');
            jsGen.writeStartArray();
            
            // adding loan owners as recipients 
            jsGen.writeId(objLoan.OwnerId);
            
            jsGen.writeEndArray();
            // Notification titile
            jsGen.writeStringField('title', objLoan.Name + ' is due for payment');
            // Notification body
            jsGen.writeStringField('body', objLoan.Name + ' is due for payment');
            jsGen.writeStringField('targetId', objLoan.Id);
            jsGen.writeEndObject();
        }

        jsGen.writeEndArray();
        jsGen.writeEndObject();
        
        // Converting JSON as a String
        String strJsonBody = jsGen.getAsString();
        System.debug('strJsonBody found '+strJsonBody);
        
        // POST URL to send custom notification
        String strPOSTURL = 'actions/standard/customNotificationAction';
        prepareNotificationData(strPOSTURL, 'POST', strJsonBody);

    }
    public static String prepareNotificationData(String strResourceName, String strMethod, String strBody) {
        String response;
        String strEndPonitURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v46.0/' + strResourceName;
        if(String.isNotBlank(strResourceName)) {
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod(strMethod);   
            httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
            httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
            
            if(String.isNotBlank(strBody)) {
                httpRequest.setBody(strBody);
                httpRequest.setHeader('Content-Type', 'application/json');
                httpRequest.setHeader('Accept', 'application/json');
            }
            
            httpRequest.setEndpoint(strEndPonitURL); 
            
            try {  
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequest);  
                if (httpResponse.getStatusCode() == 200 ) {  
                    response = httpResponse.getBody();  
                } 
                else {  
                    throw new CalloutException(httpResponse.getBody());  
                }   
            } 
            catch(Exception ex) {  
                throw ex;  
            }  
        } 
        return response;
    }
    
}