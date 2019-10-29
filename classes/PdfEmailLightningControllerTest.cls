/* --------------------------------------------------------------------------------------------------
     Name:            PdfEmailLightningControllerTest.cls 
     Description:     Test Class for Aura controller PdfEmailLightningController
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class PdfEmailLightningControllerTest {

	private static final String UTF_ENCODE = 'UTF-8';
	private static final String SHARE_TYPE = 'I';
	private static final String CONTENT_LOCATION = 'S';
	private static final String TEST_RECORD_TYPE = 'Confidential Project';

	
    /**
	 * @description Test sending the email for meeting record. 
	 * 
	 **/
	@isTest private static void runPositiveTests() {

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

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
		Map<Id, List<String>> meetingMap;
		List<String> emailList;
		String name = 'Test Attachment';
		Blob bodyBlob = Blob.valueOf('Test Attachment Body');
		string description = 'Test Description';

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
		Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Account acc = new Account(Name = 'testAccount', RecordTypeId = accountRecordTypeInfo.get(TEST_RECORD_TYPE).getRecordTypeId());
		Database.insert(acc);

		//Set up user
		System.RunAs(user) {

			meetingList = new List<Meeting__c> ();
			Meeting__c meeting;
			for (integer i = 0; i < 2; i++) {
				meeting = new Meeting__C();
				meeting.Account__c = acc.Id;
				meeting.Incomplete__c = True;
				meetingList.add(meeting);
			}
			Database.insert(meetingList);

			Meeting__c m = [SELECT Id, Name, CreatedBy.Email, CreatedById FROM Meeting__c
			                WHERE CreatedDate = TODAY
			                and CreatedById = :user.Id LIMIT 1];

			User_Attendee__c santanderAttendee = new User_Attendee__c(User__c = user.Id, Meeting__c = m.Id);
			Database.insert(santanderAttendee);

			if (emailList == null) {
				emailList = new List<String> ();
			}
			emailList.add(m.CreatedBy.Email);
			

			meetingMap = new Map<Id, List<String>> ();
			meetingMap.put(m.Id, emailList);

			ContentVersion cv = new ContentVersion();
			cv.ContentLocation = CONTENT_LOCATION;
			cv.VersionData = bodyBlob;
			cv.Title = name;
			cv.PathOnClient = name;
			cv.Description = description;
			Database.insert(cv);

			cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1000];

			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1000].ContentDocumentId;
			cdl.LinkedEntityId = m.Id;
			cdl.ShareType = SHARE_TYPE;
			Database.insert(cdl);

			PageReference pref = Page.PdfEmailer;
			pref.getParameters().put('id', m.Id);
			Test.setCurrentPage(pref);

			Test.startTest();
			PdfEmailLightningController.sendEmailFromPage(m.Id, emailList);
			Meeting__c meetingRecord = [SELECT Id, Account__c, Attachment_Added__c, Incomplete__c FROM Meeting__c WHERE Id = :m.Id LIMIT 1000];
			Test.stopTest();
			system.assert(meetingRecord.Attachment_Added__c);
			System.assertEquals(user.Email, emailList[0]);
		}
	}
	
	
    /**
	 * @description Test the negative testing for sending PDF over email. 
	 * 
	 **/
	@isTest private static void runNegativeTests() {

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

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
		Map<Id, List<String>> meetingMap;
		List<String> emailList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
		Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Account acc = new Account(Name = 'testAccount', RecordTypeId = accountRecordTypeInfo.get(TEST_RECORD_TYPE).getRecordTypeId());
		Database.insert(acc);

		//Set up user
		System.RunAs(user) {

			meetingList = new List<Meeting__c> ();
			Meeting__c meeting;
			for (integer i = 0; i < 2; i++) {
				meeting = new Meeting__C();
				meeting.Account__c = acc.Id;
				meeting.Incomplete__c = True;
				meetingList.add(meeting);
			}
			Database.insert(meetingList);

			Meeting__c m = [SELECT Id, Name, CreatedBy.Email, CreatedById FROM Meeting__c
			                WHERE CreatedDate = TODAY
			                and CreatedById = :user.Id LIMIT 1];
			if (emailList == null) {
				emailList = new List<String> ();
			}
			emailList.add('test123');
			

			meetingMap = new Map<Id, List<String>> ();
			meetingMap.put(m.Id, emailList);

			PageReference pref = Page.PdfEmailer;
			pref.getParameters().put('id', m.Id);
			Test.setCurrentPage(pref);

			Test.startTest();
			try {
				PdfEmailLightningController.sendEmailFromPage(m.Id, emailList);
			}

			catch(Exception e) {
				String expectedEmail = 'test123';
			}

			Test.stopTest();
			System.assertEquals('test123', emailList[0]);
		}
	}
    
    /**
     * @description Tests functionality which gets information about current User
     **/
    @isTest private static void testGetCurrentUserInfo() {
        User testUser = PrepareTestData.getRunningUser('System Administrator');
        Database.insert(testUser);
        System.runAs(testUser) {
            Test.startTest();
            User resultUser = PdfEmailLightningController.getUserById(testUser.Id);
            Test.stopTest();
            System.assertEquals(testUser.Email, resultUser.Email);
        }
    }

	
    /**
	 * @description Test for PDF email . 
	 **/
	@isTest private static void runOtherTests() {

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

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
		Map<Id, List<String>> meetingMap;
		List<String> emailList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
		Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Account acc = new Account(Name = 'testAccount', RecordTypeId = accountRecordTypeInfo.get(TEST_RECORD_TYPE).getRecordTypeId());
		Database.insert(acc);

		//Set up user
		System.RunAs(user) {

			meetingList = new List<Meeting__c> ();
			Meeting__c meeting;
			for (integer i = 0; i < 2; i++) {
				meeting = new Meeting__C();
				meeting.Account__c = acc.Id;
				meeting.Incomplete__c = True;
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
			

			meetingMap = new Map<Id, List<String>> ();
			meetingMap.put(m.Id, emailList);

			PageReference pref = Page.PdfEmailer;
			pref.getParameters().put('id', m.Id);
			Test.setCurrentPage(pref);

			Test.startTest();
			PdfEmailLightningController.sendEmailFromPage(m.Id,emailList);
			Meeting__c meetingRecord = [SELECT Id, Account__c, Attachment_Added__c, Incomplete__c FROM Meeting__c WHERE Id = :m.Id LIMIT 1000];

			Test.stopTest();
			system.assertEquals(false, meetingRecord.Attachment_Added__c);
			System.assertEquals(user.Email, emailList[0]);
		}
	}
}