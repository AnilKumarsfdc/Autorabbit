@isTest
private  class FCAAuthorisationSyncCleanup_Test {
    @testSetup static void setup() {
        
        
        // Create common test accounts
        List<Account> accountList = (List<Account>)TestFactory.createNewSobject('Account', 1);
        List<Account> formatedAccountList = new List<Account>();
        for(Account acc : accountList){
            acc.AccountNumber = TestFactory.generateRandomString(40);
            acc.Country_of_Incorporation__c = 'GB';
            formatedAccountList.add(acc);
        }

        insert formatedAccountList;
        
        
        // Create common test Company Social Media records
        List<FCAAuthorisation__c> cmpMediaList = (List<FCAAuthorisation__c>)TestFactory.createNewSobject('FCAAuthorisation__c', 10);
        List<FCAAuthorisation__c> formatedCmpMediaList = new List<FCAAuthorisation__c>();
        for(FCAAuthorisation__c cmpMedia : cmpMediaList){
            cmpMedia.CompanyId__c = formatedAccountList[0].Id;
            cmpMedia.IsNeworUpdatedByExternalProvider__c = false;
            formatedCmpMediaList.add(cmpMedia);
        }

        insert formatedCmpMediaList;
        
  
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new FCAAuthorisationSyncCleanup());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
    
}