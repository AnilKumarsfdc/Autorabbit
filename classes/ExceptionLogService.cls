public with sharing class ExceptionLogService {
    public static Id insertExceptionLogRecord(Exception_Log__c exceptionObj){
        Id logRecordId = ExceptionLogSelectorWS.insertExceptionLogRecord(exceptionObj);
        
        return logRecordId;
    }
    public static Id insertExceptionLogRecordAndPrintDebugStatements(String className, String methodName, Exception  e, String Priority){
        Id recordId;
        ExceptionHandlingSettings__c configObj =  ExceptionHandlingSettings__c.getOrgDefaults();
        if(configObj!= null && configObj.LoggingEnabled__c){   
            try{
    		
                String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
                String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
                String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
                String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
                //system.debug('-----ExceptionLogService-----'+QueryLimit);
                String message = 'Error: ' + e.getMessage() + '; Stack Trace:' + e.getStackTraceString();
                recordId = ExceptionLogSelectorWS.insertExceptionLogRecord(className,  methodName, message,  Priority);   
                
                if(!configObj.GenericExceptionOccurred__c){
                    sendAuthErrorNotifMail(message);
                }
                
                configObj.GenericExceptionOccurred__c = true;
                update configObj;
           	 
            } catch (Exception exc) {
            }
        }
        return recordId;
    } 
    
    public static Id insertExceptionLogRecordAndPrintDebugStatements(String className, String methodName, String message, String Priority){
        Id recordId;
                ExceptionHandlingSettings__c configObj =  ExceptionHandlingSettings__c.getOrgDefaults();
          
     if(configObj!= null && configObj.LoggingEnabled__c){
        try{
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            system.debug('-----ExceptionLogService-----'+QueryLimit);
            recordId =  ExceptionLogSelectorWS.insertExceptionLogRecord(className,  methodName, message,  Priority);    
            
            if(!configObj.GenericExceptionOccurred__c){
                sendAuthErrorNotifMail(message);
            }
            
            configObj.GenericExceptionOccurred__c = true;
            update configObj;
            
        } catch (Exception exc) {
            
        }  
     }
        return recordId;
    }
    
    public static Id insertExceptionLogRecordAndPrintDebugStatements(String className, String methodName, String exceptionMessage, String stackTraceString, String Priority){
        Id recordId;
                ExceptionHandlingSettings__c configObj =  ExceptionHandlingSettings__c.getOrgDefaults();
     if(configObj!= null && configObj.LoggingEnabled__c){
        try{
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            system.debug('-----ExceptionLogService-----'+QueryLimit);
            recordId =  ExceptionLogSelectorWS.insertExceptionLogRecord(className,  methodName, ExceptionLogService.createLogExceptionErrorMessageFromException(exceptionMessage,stackTraceString),  Priority);           
            
            if(!configObj.GenericExceptionOccurred__c){
                sendAuthErrorNotifMail(exceptionMessage);
            }
            
            configObj.GenericExceptionOccurred__c = true;
            update configObj;
            
        } catch (Exception exc) {
        }  
     }
        return recordId;
    } 
    
    public static String createLogExceptionErrorMessageFromException(String pMessage, String pStrackTraceString){
        return 'Error: ' + pMessage + '; Stack Trace:' + pStrackTraceString; 
    }
    
    public static String createLogExceptionErrorMessageFromException(Exception e){
        return ExceptionLogService.createLogExceptionErrorMessageFromException(e.getMessage(), e.getStackTraceString());
    }
    
    public static void sendAuthErrorNotifMail(String emailContent) {
        String toAddress = EntitySearchSettingService.getCurrentEntitySearchSetting().AuthenticationFailureRecipientEmail__c;
        List<String> toAddresses = new List<String>{toAddress};
        EmailTemplate et=[Select Id,Body,DeveloperName,HtmlValue,Subject from EmailTemplate where DeveloperName = 'DueDilErrorNotification' limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('DueDil Integration User');
        mail.setTemplateId(et.id);
        mail.setSubject(et.Subject);
        mail.setPlainTextBody(et.Body.replace('{MailContent}', emailContent));        
        mail.setToAddresses(toAddresses);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}