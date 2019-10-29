@isTest
private  class CharityClassifierSyncCleanupJob_Test {
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
        
        // Create common test Charity Classifier records
        List<CharityClassifier__c> charityClassifierList = (List<CharityClassifier__c>)TestFactory.createNewSobject('CharityClassifier__c', 10);
        List<CharityClassifier__c> formatedCharityClassifierList = new List<CharityClassifier__c>();
        for(CharityClassifier__c charityClassifier : charityClassifierList){
            charityClassifier.CharityId__c = formatedAccountList[0].Id;
            charityClassifier.IsNeworUpdatedByExternalProvider__c = false;
            formatedCharityClassifierList.add(charityClassifier);
        }

        insert formatedCharityClassifierList;
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new CharityClassifierSyncCleanupJob());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
}