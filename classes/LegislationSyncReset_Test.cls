@isTest
private  class LegislationSyncReset_Test {
    @testSetup static void setup() {
        // Create common test Disqualification records
           List<Contact> Officer = (List<Contact>)TestFactory.createNewSobject('Contact', 1);
        insert Officer;
        List<Legislation__c> legislationList = (List<Legislation__c>)TestFactory.createNewSobject('Legislation__c', 10);
        List<Legislation__c> formatedlegislationList = new List<Legislation__c>();
        for(Legislation__c legislation : legislationList){
            legislation.IsNeworUpdatedByExternalProvider__c = true;
            legislation.OfficerId__c = Officer[0].Id;
            formatedlegislationList.add(legislation);
        }

        insert formatedlegislationList;
    }

    @IsTest
    static void testBatchReset(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new LegislationSyncReset());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful reset, failed');
        
    }
}