/* --------------------------------------------------------------------------------------------------
     Name:            SnMeetingTriggerHandler.cls 
     Description:     Handler class for SnMeetingTrigger
  Test class:      SnMeetingTriggerHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public without sharing class SnMeetingTriggerHandler {


	/**
	 * @description This method is used to process Before Insert Functionalities  .
	 * 
	 **/
	public static void processBeforeInsert(List<Meeting__c> meetingList) {
		try {
			insertMeetingRecords(meetingList);
		}
		catch(Exception e) {
			throw e;
		}
	}


	/**
	 * @description Insert Meeting Records with Record Types based on Meeting Type from DMA  .
	 * 
	 **/
	public static void insertMeetingRecords(List<Meeting__c> mList) {
		try { 
			Map<String, String> recordTypeIdsMap = new Map<String, String> ();
			Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Meeting__c.getRecordTypeInfosByName();
			for (String recordTypeName : recordTypeInfoMap.keySet()) {
				recordTypeIdsMap.put(recordTypeName, recordTypeInfoMap.get(recordTypeName).getRecordTypeId());
			}

			for (Meeting__c meetingRecord : mList) {
				if (recordTypeIdsMap.containsKey(meetingRecord.Meeting_Type__c)) {
					meetingRecord.RecordTypeId = recordTypeIdsMap.get(meetingRecord.Meeting_Type__c);
				}
			}
		}
		catch(Exception e) {
			throw e;
		}
	}


	/**
	 * @description Send Copy of Meeting Record as PDF when a copy is requested from DMA  .
	 * 
	 **/
	@future(callout = true)
	public static void postEmail(Set<Id> meetingIds) {
		try {
			Map<Id, List<string>> mapMeetingIdEmailList = new Map<Id, List<string>> ();

			for (Meeting__c meeting :[SELECT Id, Name, CreatedById, CreatedBy.Email FROM Meeting__c WHERE Id IN :meetingIds LIMIT 1000])
			{
				mapMeetingIdEmailList.put(meeting.Id, new List<String> { meeting.CreatedBy.Email });
			}
			//Pass the map to send email with an attachment of meeting record
			PdfEmailLightningController.sendPdf(mapMeetingIdEmailList);
		}
		catch(Exception e) {
			throw e;
		}
	}
}