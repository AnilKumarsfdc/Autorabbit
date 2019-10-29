@isTest (SeeAllData=false)
private class AttachmentCheckerTest {
    
    private static testMethod void runPositiveTests() {
        test.startTest();
        Account acc = new Account(Name='Test', AnnualRevenue = 60000) ;
        insert acc;
        
        Meeting__c meeting = new Meeting__c(Account__c= acc.Id ,Attachment_Added__c=false, Incomplete__c = True);
        insert meeting;
        
        Attachment attach=new Attachment(); 
        
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=meeting.id;
        insert attach;
        if(attach.ParentId.getSobjectType() == Meeting__c.SobjectType){
            List<Attachment> attachments=[select id, name from Attachment where parent.id=:meeting.id];
            System.assertEquals(1, attachments.size());
        }
        Meeting__c meetingAfterAddingAttachment = [Select Attachment_Added__c from Meeting__c where id = :attach.ParentId];
        System.assertEquals(true, meetingAfterAddingAttachment.Attachment_Added__c);
        test.stopTest();
    }
    
}