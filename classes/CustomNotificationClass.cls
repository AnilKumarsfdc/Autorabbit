public class CustomNotificationClass {
/*    
    public static void sendCustomNotification(String strNotifiTypeDevName, list<sObject> lstObjects, list<Id> lstRecipients,String Notificationtitle, String NotificationBody) {
        String strResponse = null;
        if(String.isNotBlank(strNotifiTypeDevName)) {
            // Tooling API query
            String strResourceQuery = 'tooling/query/?q=select+id,customNotifTypeName+from+CustomNotificationType+where+DeveloperName=\''+ strNotifiTypeDevName +'\'';
            
            // OrgREST Custom Class returns the response as string
            strResponse = OrgREST.retriveResult(strResourceQuery, 'GET', null);
        }
        map<String, Object> objData;
        
        if(String.isNotBlank(strResponse)) {
            // Deserializeing the response body
            map<String, Object> mapJsonData = (map<String, Object>)JSON.deserializeUntyped(strResponse);
            
            // Getting records
            list<Object> lstRecordsData = (list<Object>)mapJsonData.get('records');
            
            if(!lstRecordsData.isEmpty()) {
                // Converting each object to readable map to get the data
                objData = (map<String, Object>)lstRecordsData[0];      
            } 
            System.debug('Id ====> '+(String)objData.get('Id'));
        }
        
        if(!lstObjects.isEmpty() && !lstRecipients.isEmpty()) {
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeFieldName('inputs');
            jsGen.writeStartArray();
            
            for(sObject obj : lstObjects) {
                jsGen.writeStartObject();
                // Custom Notification type id
                jsGen.writeStringField('customNotifTypeId', (String)objData.get('Id'));
                jsGen.writeFieldName('recipientIds');
                jsGen.writeStartArray();
                
                // adding mulitiple recipients if any 
                for(Id idRecipient : lstRecipients) {
                    jsGen.writeId(idRecipient);
                }
                
                jsGen.writeEndArray();
                // Notification titile
                jsGen.writeStringField('title', Notificationtitle);
                // Notification body
                jsGen.writeStringField('body', NotificationBody);
                jsGen.writeStringField('targetId', (String)obj.get('Id'));
                jsGen.writeEndObject();
            }
    
            jsGen.writeEndArray();
            jsGen.writeEndObject();
            
            // Converting JSON as String
            String strJson = jsGen.getAsString();
            System.debug('strJson ====> '+strJson);
            
            // POST URL to send custom notification
            String strPOSTURL = 'actions/standard/customNotificationAction';
            
            // Sending post request to send custom notification
            String strPostResponse = OrgREST.retriveResult(strPOSTURL, 'POST', strJson);
        }
    }
    //List<LLC_BI__Loan__c> loanRecords=   [SELECT Id, Name,LLC_BI__Stage__c,LLC_BI__Status__c,LLC_BI__Amount__c,Active_Loan_LTV__c,Risk_Group__c FROM LLC_BI__Loan__c where Id='a3Z9E0000002tF7UAI'];
//CustomNotificationClass.sendCustomNotification('Santander_Alert_Notifications', loanRecords, new list<Id>{UserInfo.getUserId()},'Farah','Sheba');
*/
}