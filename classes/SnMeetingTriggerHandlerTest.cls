/* --------------------------------------------------------------------------------------------------
     Name:            SnMeetingTriggerHandlerTest.cls 
     Description:     Test Class for SnMeetingTriggerHandler  
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class SnMeetingTriggerHandlerTest {
	
	private static final String PROFILE_NAME = 'System Administrator';
	private static final String TEST_RECORD_TYPE = 'Confidential Project';
	private static final String MEETING_CANCELLED = 'Meeting Cancelled/Deferred';

	/**
	 * @description Test for setting up source using lightning component  . 
	 * 
	 **/
	@isTest private static void runPositiveTests() {

		Profile profileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME LIMIT 1];

		User user = new User(LastName = 'Test',
		                     FirstName = 'User',
		                     Alias = 'utest',
		                     Email = 'santander@test.com',
		                     Username = 'santander@test.com',
		                     ProfileId = profileId.id,
		                     TimeZoneSidKey = 'GMT',
		                     LanguageLocaleKey = 'en_US',
		                     EmailEncodingKey = 'UTF-8',
		                     LocaleSidKey = 'en_US'
		);

		List<Meeting__c> meetingList;
		Set<Id> mIds;
		List<String> emailList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
		Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Account acc = new Account(Name = 'testAccount', RecordTypeId = accountRecordTypeInfo.get(TEST_RECORD_TYPE).getRecordTypeId());
		Database.insert(acc);

		//Set up user
		system.RunAs(user) {

			meetingList = new List<Meeting__c> ();
			Meeting__c meeting;
			for (integer i = 0; i < 2; i++) {
				meeting = new Meeting__C();
				meeting.Account__c = acc.Id;
				meeting.Start_DateTime__c = system.now();
				meeting.End_DateTime__c = system.now();
				meeting.Incomplete__c = True;
				meeting.Meeting_Type__c = 'Meeting Cancelled/Deferred';
				meetingList.add(meeting);
			}
			Database.insert(meetingList);

			Meeting__c m = [SELECT Id, Name, CreatedBy.Email, CreatedById FROM Meeting__c
			                WHERE CreatedDate = TODAY
			                and CreatedById = :user.Id LIMIT 1];
			if (emailList == null) {
				emailList = new List<String> ();
			}
			emailList.add(m.CreatedBy.Email);

			

			mIds = new Set<Id> ();
			mIds.add(m.Id);

			Test.startTest();
			SnMeetingTriggerHandler.postEmail(mIds);
			Test.stopTest();
			system.assertEquals(user.Email, emailList[0]);
		}
	}

	/**
	 * @description Test for sending the Meeting template   . 
	 * 
	 **/
	@isTest private static void sendACopyTest() {

		Profile profileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME LIMIT 1];

		User user = new User(LastName = 'Test',
		                     FirstName = 'User',
		                     Alias = 'utest',
		                     Email = 'santander@test.com',
		                     Username = 'santander@test.com',
		                     ProfileId = profileId.id,
		                     TimeZoneSidKey = 'GMT',
		                     LanguageLocaleKey = 'en_US',
		                     EmailEncodingKey = 'UTF-8',
		                     LocaleSidKey = 'en_US'
		);

		List<Meeting__c> meetingList;
		Set<Id> mIds;
		List<String> emailList;
		Boolean bool = true;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
		Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Account acc = new Account(Name = 'testAccount', RecordTypeId = accountRecordTypeInfo.get(TEST_RECORD_TYPE).getRecordTypeId());
		Database.insert(acc);

		//Set up user
		system.RunAs(user) {

			meetingList = new List<Meeting__c> ();
			Meeting__c meeting;
			for (integer i = 0; i < 2; i++) {
				meeting = new Meeting__C();
				meeting.Account__c = acc.Id;
				meeting.Start_DateTime__c = system.now();
				meeting.End_DateTime__c = system.now();
				meeting.Incomplete__c = True;
				meeting.Send_me_a_Copy__c = True;
				meetingList.add(meeting);
			}
			Database.insert(meetingList);

			Meeting__c m = [SELECT Id, Name, CreatedBy.Email, CreatedById, Send_me_a_Copy__c FROM Meeting__c
			                WHERE CreatedDate = TODAY
			                and CreatedById = :user.Id LIMIT 1];
			if (emailList == null) {
				emailList = new List<String> ();
			}
			emailList.add(m.CreatedBy.Email);

			

			mIds = new Set<Id> ();
			mIds.add(m.Id);

			Test.startTest();
			SnMeetingTriggerHandler.postEmail(mIds);
			Test.stopTest();
			system.assertEquals(user.Email, emailList[0]);
			system.assertEquals(bool, m.Send_me_a_Copy__c);
		}
	}

	/**
	 * @description Test for setting up source using lightning component  . 
	 * 
	 **/
	 @isTest private static void runOtherTests() {

		Id meetingRecordId = Schema.SObjectType.Meeting__c.getRecordTypeInfosByName().get(MEETING_CANCELLED).getRecordTypeId();
		Profile profileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME LIMIT 1];

		User user = new User(LastName = 'Test',
		                     FirstName = 'User',
		                     Alias = 'utest',
		                     Email = 'santander@test.com',
		                     Username = 'santander@test.com',
		                     ProfileId = profileId.id,
		                     TimeZoneSidKey = 'GMT',
		                     LanguageLocaleKey = 'en_US',
		                     EmailEncodingKey = 'UTF-8',
		                     LocaleSidKey = 'en_US'
		);
	system.runAs(user){
		Account acc = new Account(Name = 'testAccount');
		Database.insert(acc);

		List<Meeting__c> meetingList = new List<Meeting__c> ();
		Meeting__c meeting;
		for (integer i = 0; i < 2; i++) {
			meeting = new Meeting__C();
			meeting.Account__c = acc.Id;
			meeting.Start_DateTime__c = system.now();
			meeting.End_DateTime__c = system.now();
			meeting.Incomplete__c = True;
			meeting.Meeting_Type__c = 'Meeting Cancelled/Deferred';
			meetingList.add(meeting);
		}
		Database.insert(meetingList);

		Test.startTest();
		SnMeetingTriggerHandler.insertMeetingRecords(meetingList);

		Meeting__c meetingRecord = [SELECT Id, RecordTypeId, Send_me_a_Copy__c FROM Meeting__c LIMIT 1];
		

		meetingRecord.Send_me_a_Copy__c = true;
		Database.update(meetingRecord);

		Test.stopTest();
		system.assertEquals(meetingRecordId, meetingRecord.RecordTypeId);
		system.assert(meetingRecord.Send_me_a_Copy__c, 'Send me a copy has been marked as successful;');
		
	}
		
	}
}