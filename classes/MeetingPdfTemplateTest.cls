/* --------------------------------------------------------------------------------------------------
     Name:            MeetingPdfTemplateTest.cls 
     Description:     Test Class for controller MeetingPdfTemplateExtension.cls
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class MeetingPdfTemplateTest {
	/** 
	 * @description : This method runs runPositiveTests
	 **/
	private static testMethod void runPositiveTests() {
		// Setup test data
		// This code runs as the system user
		User u = PrepareTestData.getRunningUser();
		System.runAs(u) {


			List<Meeting__c> meeting;
			Map<Id, Meeting__c> meetingCacheMap;

			Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
			Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

			Account acc = new Account(Name = 'testAccount', RecordTypeId = accountRecordTypeInfo.get('Confidential Project').getRecordTypeId());
			Database.insert(acc);
            
            Contact con = new Contact(LastName = 'Company Attendee', AccountId = acc.Id);
            Database.Insert(con);

			meeting = new List<Meeting__c> ();
			Meeting__c m1 = new Meeting__c(Account__c = Acc.Id, Incomplete__c = True);
			Meeting__c m2 = new Meeting__c(Account__c = Acc.Id, Incomplete__c = True);
			meeting.add(m1);
			meeting.add(m2);
			Database.insert(meeting);
            
            Contact_Attendee__c conAttendee = new Contact_Attendee__c(Meeting__c = m1.Id, Contact__c = con.Id);
            Database.insert(conAttendee);
            
            User_Attendee__c sanAttendee = new  User_Attendee__c(Meeting__c = m1.Id, User__c = u.Id);
            Database.insert(sanAttendee);
            
            Meeting_Company_Relation__c meetingCompanyRelation =  new Meeting_Company_Relation__c(Meeting__c = m1.id,Company__c = acc.id);
			Database.insert(meetingCompanyRelation);
			
			Meeting__c m = [SELECT Id, Name, CreatedBy.Email, CreatedById FROM Meeting__c
			                WHERE CreatedDate = TODAY LIMIT 1];
			meetingCacheMap = new Map<Id, Meeting__c> ();
			meetingCacheMap.put(m.Id, m);

			ApexPages.StandardController sc = new ApexPages.StandardController(m);
			MeetingPdfTemplateExtension meetingExt = new MeetingPdfTemplateExtension(sc);

			PageReference pageRef = page.MeetingRecordTemplate1;
			pageRef.getParameters().put('Id', m.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			meetingExt.cachedMeetingId = m.Id;
			meetingExt.getSantanderAttendees();
			meetingExt.getContactAttendees();
			meetingExt.getRelatedCompanies();
			Test.stopTest();
			system.assertEquals(u.Email, m.CreatedBy.Email);
		}
	}
}