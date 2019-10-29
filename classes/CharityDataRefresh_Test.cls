@isTest
private  class CharityDataRefresh_Test {
    @testSetup static void setup() {
        // Create common test accounts
       Test.startTest();
        List<Account> accountList = (List<Account>)TestFactory.createNewSobject('Account', 200);
        List<Account> formatedAccountList = new List<Account>();
        for(Account acc : accountList){
            acc.CharityId__c = TestFactory.generateRandomString(40);
            acc.CharityCountryCode__c = 'GB';
            formatedAccountList.add(acc);
        }

        insert formatedAccountList;
		
		Test.stopTest();
    }

    @IsTest
    static void testBatchIntegration(){
        Id batchJobId;
        Test.startTest();
        
       
        
             // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('HierarchyCalloutTest');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            
          //  batchJobId = Database.executeBatch(new CharityDataRefresh());
          CharityDataRefresh myBatchObject = new CharityDataRefresh(BulkAPIStatusManagement.createBulkJobLogRecord(true)); 
          batchJobId = Database.executeBatch(myBatchObject, 200);
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful callout, failed');
        
    }

    @IsTest
    static void testBatchIntegrationFailure(){
        Id batchJobId;
        Test.startTest();
            
        	// Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('HierarchyCalloutTest');
            mock.setStatusCode(404);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            batchJobId = Database.executeBatch(new CharityDataRefresh());
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test un-successful callout, failed');
    }
    
     @IsTest
    static void testBatchIntegrationAuthFailure(){
        Id batchJobId;
        Test.startTest();
            
        	// Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('HierarchyCalloutTest');
            mock.setStatusCode(401);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            batchJobId = Database.executeBatch(new CharityDataRefresh());
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test un-successful callout, failed');
    }

    @IsTest
    static void testSchdeduledBatchIntegration(){
        String cronExpr = '0 0 0 15 3 ? 2022';
        Id scheduledJobId;

        Test.startTest();
            
        	// Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('HierarchyCalloutTest');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            scheduledJobId = System.schedule('Test Scheduled Batch', cronExpr, new CharityDataRefresh());
                
        Test.stopTest();
        CronTrigger cronTrigger = [SELECT Id, State, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :scheduledJobId];
        // Assert that the Cron job has run once

        System.assertEquals('WAITING', cronTrigger.state, 'Batch not scheduled');
    } 
}