/* --------------------------------------------------------------------------------------------------
   Name:            AttachmentTriggerHandlerTest.cls 
   Description:     Test Class for Trigger Handler AttachmentTriggerHandler

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   23-April-2017          0.1       Rohit Middha    
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private class AttachmentTriggerHandlerTest {
    /**
	 * @description Test for adding attachment 
	 * 
	 **/
   @isTest private static void runPositiveTests() {
        
        Account acc = new Account(Name='Test', AnnualRevenue = 60000) ;
        Database.insert(acc);
        
        Meeting__c meeting = new Meeting__c(Account__c= acc.Id ,Attachment_Added__c=false, Incomplete__c = True);
        Database.insert(meeting);
        
        Attachment attach=new Attachment(); 
        
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=meeting.id;
        Database.insert(attach);

		test.startTest();
       
            List<Attachment> attachments=[SELECT Id, name from Attachment WHERE parent.Id=:meeting.Id LIMIT 1000];
		test.stopTest();

        Meeting__c meetingAfterAddingAttachment = [Select Attachment_Added__c from Meeting__c where Id = :attach.ParentId LIMIT 1000];
        System.assertEquals(true, meetingAfterAddingAttachment.Attachment_Added__c);
        System.assertEquals(1, attachments.size());
    }
}