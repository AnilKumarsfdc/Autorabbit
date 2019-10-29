@isTest
private  class CompanyFilingSyncCleanup_Test {
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
        List<CompanyFilings__c> cmpFilingList = (List<CompanyFilings__c>)TestFactory.createNewSobject('CompanyFilings__c', 10);
        List<CompanyFilings__c> formatedcmpFilingList = new List<CompanyFilings__c>();
        for(CompanyFilings__c cmpFiling : cmpFilingList){
            cmpFiling.CompanyId__c = formatedAccountList[0].Id;
            cmpFiling.IsNeworUpdatedByExternalProvider__c = false;
            formatedcmpFilingList.add(cmpFiling);
        }

        insert formatedcmpFilingList;
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new CompanyFilingSyncCleanup());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
}