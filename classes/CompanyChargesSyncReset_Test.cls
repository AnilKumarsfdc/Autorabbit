@isTest
private  class CompanyChargesSyncReset_Test {
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
        
        // Create common test Company Charge records
        List<CompanyCharges__c> cmpChargeList = (List<CompanyCharges__c>)TestFactory.createNewSobject('CompanyCharges__c', 10);
        List<CompanyCharges__c> formatedCmpChargeList = new List<CompanyCharges__c>();
        for(CompanyCharges__c cmpCharge : cmpChargeList){
            cmpCharge.Company__c = formatedAccountList[0].Id;
            cmpCharge.IsNeworUpdatedByExternalProvider__c = true;
            formatedCmpChargeList.add(cmpCharge);
        }

        insert formatedCmpChargeList;
    }

    @IsTest
    static void testBatchReset(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new CompanyChargesSyncReset());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful reset, failed');
        
    }
}