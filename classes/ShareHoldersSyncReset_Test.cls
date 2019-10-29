@isTest
private  class ShareHoldersSyncReset_Test {
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
        
        // Create common test Shareholders records
        List<Shareholders__c> shareHolderList = (List<Shareholders__c>)TestFactory.createNewSobject('Shareholders__c', 10);
        List<Shareholders__c> formatedShareHolderList = new List<Shareholders__c>();
        for(Shareholders__c shareHolder : shareHolderList){
            shareHolder.CompanyId__c = formatedAccountList[0].Id;
            shareHolder.IsNeworUpdatedByExternalProvider__c = true;
            formatedShareHolderList.add(shareHolder);
        }

        insert formatedShareHolderList;
    }

    @IsTest
    static void testBatchReset(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new ShareHoldersSyncReset());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful reset, failed');
        
    }
}