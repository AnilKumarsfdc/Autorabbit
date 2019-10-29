public class OrgREST {
/*    public static String retriveResult(String strResourceName, String strMethod, String strBody) {
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
*/
}