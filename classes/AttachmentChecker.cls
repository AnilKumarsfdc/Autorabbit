public class AttachmentChecker {

    public static void attachmentCheck(Set<Id> mIds) {
       List<Meeting__c> meetingList = [SELECT Id, Attachment_Added__c 
                                       FROM Meeting__c 
                                       WHERE Id IN : mIds];
        if(meetingList !=null && meetingList.size()>0){
            for(Meeting__c meeting : meetingList){
                meeting.Attachment_Added__c = true;
            }
            update meetingList;
        }
    }
}