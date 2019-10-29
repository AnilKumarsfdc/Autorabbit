/* --------------------------------------------------------------------------------------------------
     Name:            MeetingCompanyRelationshipTest.cls 
     Description:     Test Class for MeetingCompanyRelationshipTriggerHandler  
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
public class MeetingCompanyRelationshipTest {
    private static final String PROFILE_NAME = 'System Administrator';
	private static final String TEST_RECORD_TYPE = 'Customer';	
    private static final String TEST_MEETING_TYPE = 'Initial Meeting';	
    
    /**
	 * @description Test for saving new Last contacted date on company  . 
	 * 
	 **/
	@isTest private static void runPositiveTests() {

		List<Account> accList = PrepareTestData.prepareAccounts(1, true,TEST_RECORD_TYPE );

        Meeting__c meeting = new Meeting__C();
        meeting.Account__c = accList[0].Id;
        meeting.Start_DateTime__c = system.now();
        meeting.End_DateTime__c = system.now().addMinutes(20);
        meeting.Incomplete__c = True;
        meeting.Meeting_Type__c = TEST_MEETING_TYPE;
			
        Database.insert(meeting);
        
        Meeting_Company_Relation__c mcrObj = new Meeting_Company_Relation__c();
        mcrObj.Company__c = accList[0].Id;
        mcrObj.Meeting__c =meeting.Id;
        
        Test.startTest();
        	Database.insert(mcrObj);
        Test.stopTest();
        
        Account acc = [SELECT ID, Last_contacted_date__c 
                      	FROM Account
                      	WHERE Id =: accList[0].Id LIMIT 1];
        
        system.assertEquals((meeting.Start_DateTime__c).day(),(acc.Last_contacted_date__c).day());
        system.assertEquals((meeting.Start_DateTime__c).month(),(acc.Last_contacted_date__c).month());
        system.assertEquals((meeting.Start_DateTime__c).year(),(acc.Last_contacted_date__c).year());
		
	}
    
    
    /**
	 * @description Test when Last contacted date is greater than meeting reocord start date . 
	 * 
	 **/
	@isTest private static void runNegativeTests() {
        
		List<Account> accList = PrepareTestData.prepareAccounts(2, true,TEST_RECORD_TYPE );
        
        List<Meeting__c> meetingList = new List<Meeting__c>();
        Meeting__c meeting = new Meeting__C();
        meeting.Account__c = accList[0].Id;
        meeting.Start_DateTime__c = system.now();
        meeting.End_DateTime__c = system.now().addMinutes(30);
        meeting.Incomplete__c = True;
        meeting.Meeting_Type__c = TEST_MEETING_TYPE;
        meetingList.add(meeting);
        
        Meeting__c meeting2 = new Meeting__C();
        meeting2.Account__c = accList[1].Id;
        meeting2.Start_DateTime__c = system.now().addDays(-5);
        meeting2.End_DateTime__c = system.now().addDays(-5).addMinutes(30);
        meeting2.Incomplete__c = True;
        meeting2.Meeting_Type__c = TEST_MEETING_TYPE;
        meetingList.add(meeting2);
        
        Database.insert(meetingList);
        
        Test.startTest();
            Meeting_Company_Relation__c mcrObj2 = new Meeting_Company_Relation__c();
            mcrObj2.Company__c = accList[0].Id;
            mcrObj2.Meeting__c =meetingList[1].Id;
            Database.insert(mcrObj2);
        Test.stopTest();
        
        Account acc = [SELECT ID, Last_contacted_date__c 
                      	FROM Account
                      	WHERE Id =: accList[0].Id LIMIT 1];
      
        system.assertNotEquals((meetingList[1].Start_DateTime__c).day(),(acc.Last_contacted_date__c).day());       
		
	}
    
}