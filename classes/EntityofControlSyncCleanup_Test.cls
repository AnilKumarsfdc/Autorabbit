@isTest
private  class EntityofControlSyncCleanup_Test {
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
        List<EntityOfSignificantControl__c> cmpMediaList = (List<EntityOfSignificantControl__c>)TestFactory.createNewSobject('EntityOfSignificantControl__c', 10);
        List<EntityOfSignificantControl__c> formatedCmpMediaList = new List<EntityOfSignificantControl__c>();
        for(EntityOfSignificantControl__c cmpMedia : cmpMediaList){
            cmpMedia.CompanyofSignificantControl__c = formatedAccountList[0].Id;
            cmpMedia.IsNeworUpdatedByExternalProvider__c = false;
            formatedCmpMediaList.add(cmpMedia);
        }

        insert formatedCmpMediaList;
        
  
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new EntityofSignificantControlSyncCleanup());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
    
}