@isTest(SeeAllData = false)
private with sharing class ExceptionLoggerTest{
    
    @isTest
    private static void testExceptionLogger(){
        Test.startTest();
        Config_Settings__c config = new Config_Settings__c(Logging_Enabled__c = true);
        insert config;
    	Contact ContactObj = null;
        try{
            String email = ContactObj.Email;
        }catch(Exception ex){
            String message = 'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString();
            ExceptionLogger logger = ExceptionLogger.getInstance();
            logger.logException('ExceptionLoggerTest', 'nullPointerException', message, ExceptionLogger.ERROR);
        }
        Test.stopTest(); 
        Exception_Log__c excepLog = [select id,Class__c,Method__c,Priority__c,Running_User__c from Exception_Log__c limit 1]; 
        System.assertEquals('ExceptionLoggerTest', excepLog.Class__c);      
    }
}