/* --------------------------------------------------------------------------------------------------
   Name:            AttachmentTriggerHandler.cls 
   Description:     Handler Class for AttachmentTrigger.Trigger
   Test class:      AttachmentTriggerHandlerTest.cls 

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   18-February-2017       0.1       Sheshant Kashyap    Update Meeting Record when Attachment is added
  ------------------------------------------------------------------------------------------------ */
public with sharing class AttachmentTriggerHandler {
	
	/**
	 * @description : This methord will mark the checkbox to true is attachment is present.
	 * 
	 **/
    public static void attachmentCheck(Set<Id> mIds) {
       List<Meeting__c> meetingList = [SELECT Id, Attachment_Added__c 
                                       FROM Meeting__c 
                                       WHERE Id IN : mIds LIMIT 10000];
        if(meetingList !=null && meetingList.size()>0){
            for(Meeting__c meeting : meetingList){
                meeting.Attachment_Added__c = true;
            }
            try {
				Database.update(meetingList);
			}
			catch(Exception e) {
				throw e;
			}
        }
    }
}