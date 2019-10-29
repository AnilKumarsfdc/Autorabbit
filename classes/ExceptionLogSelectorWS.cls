public with sharing class ExceptionLogSelectorWS {
    
    public static Id insertExceptionLogRecord(String className, String methodName, String message, String Priority){
        // ExceptionHandlingSettings__c configObj =  ExceptionHandlingSettings__c.getOrgDefaults();
        Exception_Log__c exceptionObj = new Exception_Log__c();
        
        exceptionObj.Class__c = className;
        exceptionObj.Method__c = methodName;
        exceptionObj.Message__c = message;
        exceptionObj.Priority__c = Priority;
        exceptionObj.Running_User__c = UserInfo.getUserName(); 
        try{
            insert exceptionObj;
            System.debug('Created Exception Log record successfully.');
        }catch(Exception e){
            System.debug('Failed to Insert the Exception Logger Record' +'Error: ' + e.getMessage());              
        }
        return exceptionObj.Id;
    }
    
    public static Id insertExceptionLogRecord(Exception_Log__c exceptionObj){
        try{
            insert exceptionObj;
            System.debug('Created Exception Log record successfully.');
        }catch(Exception e){
            System.debug('Failed to Insert the Exception Logger Record' +'Error: ' + e.getMessage());              
        }
        return exceptionObj.Id;
    }
}