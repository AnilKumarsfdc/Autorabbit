@isTest
private  class AppointmentSyncReset_Test {
    @testSetup static void setup() {
        // Create common test Appointment records
        List<Account> AccountList = (List<Account>)TestFactory.createNewSobject('Account', 1);
        
        insert AccountList;
        List<Appointment__c> appointmentList = (List<Appointment__c>)TestFactory.createNewSobject('Appointment__c', 10);
        List<Appointment__c> formatedAppointmentList = new List<Appointment__c>();
        for(Appointment__c appointmentObj : appointmentList){
            appointmentObj.IsNeworUpdatedByExternalProvider__c = true;
            appointmentObj.AppointedTo__c = AccountList[0].id;
            formatedAppointmentList.add(appointmentObj);  
        }

        insert formatedAppointmentList;
    }

    @IsTest
    static void testBatchReset(){
        Id batchJobId;
        Test.startTest();
            batchJobId = Database.executeBatch(new AppointmentSyncReset());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchJobId];

        System.assertEquals('Completed', job.Status, 'Batch to test successful reset, failed');
        
    }
}