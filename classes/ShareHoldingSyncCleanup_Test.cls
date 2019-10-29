@isTest
private  class ShareHoldingSyncCleanup_Test {
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
        
        // Create common test Shareholding records
        List<Shareholders__c> shareHolderList = (List<Shareholders__c>)TestFactory.createNewSobject('Shareholders__c', 10);
        List<Shareholders__c> formatedShareHolderList = new List<Shareholders__c>();
        for(Shareholders__c shareHolder : shareHolderList){
            shareHolder.CompanyId__c = formatedAccountList[0].Id;
            shareHolder.IsNeworUpdatedByExternalProvider__c = false;
            formatedShareHolderList.add(shareHolder);
        }

        insert formatedShareHolderList;
        
        // Create common test Company Filing records
        List<Shareholding__c> shareHoldingList = (List<Shareholding__c>)TestFactory.createNewSobject('Shareholding__c', 10);
        List<Shareholding__c> formatedshareHoldingList = new List<Shareholding__c>();
        for(Shareholding__c shareHolding : shareHoldingList){
            shareHolding.Shareholders__c = formatedShareHolderList[0].Id;
            shareHolding.IsNeworUpdatedByExternalProvider__c = false;
            formatedshareHoldingList.add(shareHolding);
        }

        insert formatedshareHoldingList;
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new ShareHoldingSyncCleanup());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
}