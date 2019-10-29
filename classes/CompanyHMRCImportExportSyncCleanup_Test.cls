@isTest
private  class CompanyHMRCImportExportSyncCleanup_Test {
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
        
        // Create common test HMRC ImportExport records
        List<HMRCImportExport__c> hmrcList = (List<HMRCImportExport__c>)TestFactory.createNewSobject('HMRCImportExport__c', 10);
        List<HMRCImportExport__c> formatedHMRCList = new List<HMRCImportExport__c>();
        for(HMRCImportExport__c hmrcObj : hmrcList){
            hmrcObj.Account__c = formatedAccountList[0].Id;
            hmrcObj.IsNeworUpdatedByExternalProvider__c = false;
            formatedHMRCList.add(hmrcObj);
        }

        insert formatedHMRCList;
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new CompanyHMRCImportExportSyncCleanup());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
}