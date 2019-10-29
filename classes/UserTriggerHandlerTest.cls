/* --------------------------------------------------------------------------------------------------
     Name:            UserTriggerHandlerTest.cls 
     Description:     Test Class for Aura controller UserTriggerHandler
     Date             Version     Author              Summary of Changes 
     -----------      -------     -----------------   -------------------------------------------
     10-May-2018       0.1       Vijay Sonawane      Initial
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class UserTriggerHandlerTest {	
    private static final String BLANK_VALUE = '';
    private static final String TEST_SEGMENT = 'Test Segment';
    private static final String TEST_REGION = 'Test Region';
    private static final String GROUP_NAME1 = 'TestGroup1';
    private static final String GROUP_NAME2 = 'TestGroup2';
    private static final String COLABORATION_TYPE = 'Private';
    private static final String CUSTOM_SETTING_NAME1 = 'Test Custom Setting1';
    private static final String CUSTOM_SETTING_NAME2 = 'Test Custom Setting2';
    private static final String PROFILE_NAME = 'Standard User';
	/**
	 * @description Test for creating user and checking group membership for user 
	 * 
	 **/
	@isTest private static void testCollaborationGroupOnUserCreation() {
		
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name=GROUP_NAME1;
        cg.CollaborationType=COLABORATION_TYPE;
        Database.insert(cg);
        
        Chatter_Group_Assignments__c cga = new Chatter_Group_Assignments__c();
        cga.Name=CUSTOM_SETTING_NAME1;
        cga.Chatter_Group_Id__c = cg.Id;
        cga.Department__c = BLANK_VALUE;
        cga.Division__c = BLANK_VALUE;
        cga.Region__c = BLANK_VALUE;
        cga.Segment__c = TEST_SEGMENT;
        Database.insert(cga);
		
        List<User> usrList = PrepareTestData.prepareUser(1,false,PROFILE_NAME);
        Test.startTest();
            usrList[0].Department = BLANK_VALUE;
            usrList[0].Division = BLANK_VALUE;
            usrList[0].Region__c = BLANK_VALUE;
            usrList[0].Segment__c = TEST_SEGMENT;
            Database.insert(usrList[0]);
        Test.stopTest();
        CollaborationGroupMember cgm = [SELECT Id,MemberId,CollaborationGroupId
                                      	FROM CollaborationGroupMember WHERE MemberId =: usrList[0].Id  LIMIT 1];
                                   
        System.assertEquals(cg.Id,cgm.CollaborationGroupId);
	}
    
    /**
	 * @description Test for updating user and checking group membership change 
	 * 
	 **/
    @isTest private static void testCollaborationGroupChangeOnUserUpdate(){	
		
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name=GROUP_NAME1;
        cg.CollaborationType=COLABORATION_TYPE;
        Database.insert(cg);
        
        Chatter_Group_Assignments__c cga = new Chatter_Group_Assignments__c();
        cga.Name=CUSTOM_SETTING_NAME1;
        cga.Chatter_Group_Id__c = cg.Id;
        cga.Department__c = BLANK_VALUE;
        cga.Division__c = BLANK_VALUE;
        cga.Region__c = BLANK_VALUE;
        cga.Segment__c = TEST_SEGMENT;
        Database.insert(cga);
		
        List<User> usrList = PrepareTestData.prepareUser(1,true,PROFILE_NAME);
        Test.startTest();
            usrList[0].Department = BLANK_VALUE;
            usrList[0].Division = BLANK_VALUE;
            usrList[0].Region__c = BLANK_VALUE;
            usrList[0].Segment__c = TEST_SEGMENT;
            Database.update(usrList[0]);
        Test.stopTest();
        List<CollaborationGroupMember> cgmList = [SELECT Id,MemberId,CollaborationGroupId
                                      	FROM CollaborationGroupMember 
                                        WHERE MemberId =: usrList[0].Id 
                                        AND CollaborationGroupId =: cg.Id 
                                        LIMIT 1];
                                   
        System.assertEquals(1,cgmList.size());
	}
    
    /**
	 * @description Test for updating user and checking group membership delete change 
	 * 
	 **/
    @isTest private static void testCollaborationGroupMemberDelete(){	
		List<CollaborationGroup> l_CollaborationGroup = new List<CollaborationGroup>();
        
        CollaborationGroup cg1 = new CollaborationGroup();
        cg1.Name=GROUP_NAME1;
        cg1.CollaborationType=COLABORATION_TYPE;
        l_CollaborationGroup.add(cg1);
        
        CollaborationGroup cg2 = new CollaborationGroup();
        cg2.Name=GROUP_NAME2;
        cg2.CollaborationType=COLABORATION_TYPE;
        l_CollaborationGroup.add(cg2);
        
        Database.insert(l_CollaborationGroup);
        
        List<Chatter_Group_Assignments__c> cgaList = new List<Chatter_Group_Assignments__c>();
        Chatter_Group_Assignments__c cga1 = new Chatter_Group_Assignments__c();
        cga1.Name=CUSTOM_SETTING_NAME1;
        cga1.Chatter_Group_Id__c = cg1.Id;
        cga1.Department__c = BLANK_VALUE;
        cga1.Division__c = BLANK_VALUE;
        cga1.Region__c = TEST_REGION;
        cga1.Segment__c = BLANK_VALUE;
        cgaList.add(cga1);
        
        Chatter_Group_Assignments__c cga2 = new Chatter_Group_Assignments__c();
        cga2.Name=CUSTOM_SETTING_NAME2;
        cga2.Chatter_Group_Id__c = cg2.Id;
        cga2.Department__c = BLANK_VALUE;
        cga2.Division__c = BLANK_VALUE;
        cga2.Region__c = BLANK_VALUE;
        cga2.Segment__c = TEST_SEGMENT;
        cgaList.add(cga2);       
        
        Database.insert(cgaList);
        
        List<User> usrList = PrepareTestData.prepareUser(1,true,PROFILE_NAME);
               
        CollaborationGroupMember cgm = new CollaborationGroupMember(MemberId = usrList[0].Id, CollaborationGroupId = cg1.Id);
        Database.insert(cgm);
		
       
        Test.startTest();
            usrList[0].Department = BLANK_VALUE;
            usrList[0].Division = BLANK_VALUE;
            usrList[0].Region__c = BLANK_VALUE;
            usrList[0].Segment__c = TEST_SEGMENT;
            Database.update(usrList[0]);
        Test.stopTest();
              List<CollaborationGroupMember> cgmList = [SELECT Id,MemberId,CollaborationGroupId
                                      	FROM CollaborationGroupMember 
                                        WHERE MemberId =: usrList[0].Id 
                                        AND CollaborationGroupId =: cg2.Id 
                                        LIMIT 1];
                                   
        System.assertEquals(1,cgmList.size());
	}
    
}