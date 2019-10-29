@isTest
private class ExceptionLogService_Test {
    @testSetup static void setup() {
        // Create common test accounts
       Test.startTest();  
        ExceptionHandlingSettings__c settings = new ExceptionHandlingSettings__c();
        settings.Name = 'Global Settings';
        settings.LoggingEnabled__c = true;
        settings.GenericExceptionOccurred__c = false;
        insert settings;
        
		Test.stopTest();
        
        
    }
    
     static testmethod void insertExceptionLogRecord(){
        Test.startTest();       
             ExceptionLogService.insertExceptionLogRecord(new Exception_Log__c());
             Exception_Log__c expLog = [Select Id, Name from Exception_Log__c LIMIT 1];
             System.assert(expLog != null);
        Test.stopTest();
    }
    
     static testmethod void insertExceptionLogRecordAndPrintDebugStatementsTest(){
        Test.startTest();
            Exception exc = new BulkAPICustomException.customExtendedException('TEST_MESSAGE');
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExceptionLogService_Test', 'insertExceptionLogRecordAndPrintDebugStatementsTest', exc, 'ERROR'); 
            Exception_Log__c expLog = [Select Id, Name from Exception_Log__c LIMIT 1];
            System.assert(expLog != null);
        Test.stopTest();
    }
    
     static testmethod void insertExceptionLogRecordAndPrintDebugStatementsTest1(){
        Test.startTest();
             ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExceptionLogService_Test', 'insertExceptionLogRecordAndPrintDebugStatements', 'TEST_MESSAGE', 'ERROR');        	
             Exception_Log__c expLog = [Select Id, Name from Exception_Log__c LIMIT 1];
             System.assert(expLog != null);
        Test.stopTest();
    }
    
     static testmethod void insertExceptionLogRecordAndPrintDebugStatementsTest2(){
        Test.startTest();
             ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExceptionLogService_Test', 'insertExceptionLogRecordAndPrintDebugStatements', 'TEST_MESSAGE', 'TESTTRACESTRING', 'ERROR');        	
             Exception_Log__c expLog = [Select Id, Name from Exception_Log__c LIMIT 1];
             System.assert(expLog != null);
        Test.stopTest();
    }
    
    static testmethod void BulkAPICustomExceptionTest(){
        Test.startTest();
            BulkAPICustomException.customExtendedException custExc = new BulkAPICustomException.customExtendedException('TEST_MESSAGE');    
            BulkAPICustomException custExcAddError = new BulkAPICustomException();
            Boolean errorAdded = custExcAddError.addError('Error',false);
            System.assert(errorAdded == true);
        Test.stopTest();
    }
    
}