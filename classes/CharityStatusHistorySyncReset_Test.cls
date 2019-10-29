@isTest
private  class CharityStatusHistorySyncReset_Test {
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
        
        // Create common test Company Filing records
        List<CharityStatusHistory__c> charityStatusHistoryList = (List<CharityStatusHistory__c>)TestFactory.createNewSobject('CharityStatusHistory__c', 10);
        List<CharityStatusHistory__c> formatedCharityStatusHistoryList = new List<CharityStatusHistory__c>();
        for(CharityStatusHistory__c charityStatusHistory : charityStatusHistoryList){
            charityStatusHistory.CharityId__c = formatedAccountList[0].Id;
            charityStatusHistory.IsNeworUpdatedByExternalProvider__c = true;
            formatedCharityStatusHistoryList.add(charityStatusHistory);
        }

        insert formatedCharityStatusHistoryList;
    }

    @IsTest
    static void testBatchReset(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new CharityStatusHistorySyncReset());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful reset, failed');
        
    }
}