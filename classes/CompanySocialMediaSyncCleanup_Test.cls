@isTest
private  class CompanySocialMediaSyncCleanup_Test {
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
        List<CompanySocialMedia__c> cmpMediaList = (List<CompanySocialMedia__c>)TestFactory.createNewSobject('CompanySocialMedia__c', 10);
        List<CompanySocialMedia__c> formatedCmpMediaList = new List<CompanySocialMedia__c>();
        for(CompanySocialMedia__c cmpMedia : cmpMediaList){
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
            batchJobId = Database.executeBatch(new CompanySocialMediaSyncCleanup());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
        LaunchCompanyHierarchyCleanupProcess.invokeCleanupBatches();
    }
    
}