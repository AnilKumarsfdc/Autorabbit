@isTest
private  class AppointmentSyncCleanupJob_Test {
    @testSetup static void setup() {
        // Create common test Appointment records
         List<Account> AccountList = (List<Account>)TestFactory.createNewSobject('Account', 1);        
        insert AccountList;
        
        List<Appointment__c> appointmentList = (List<Appointment__c>)TestFactory.createNewSobject('Appointment__c', 10);
        List<Appointment__c> formatedAppointmentList = new List<Appointment__c>();
        for(Appointment__c appointmentObj : appointmentList){
            appointmentObj.IsNeworUpdatedByExternalProvider__c = false;
            appointmentObj.AppointedTo__c = AccountList[0].id;
            formatedAppointmentList.add(appointmentObj);
        }

        insert formatedAppointmentList;
    }

    @IsTest
    static void testBatchCleanup(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new AppointmentSyncCleanupJob());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful cleanup, failed');
        
    }
}