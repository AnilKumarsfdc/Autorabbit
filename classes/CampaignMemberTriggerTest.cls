/* -------------------------------------------------------------------------------------------------- 
   Description:     Test Class which checks functionality of CampaignMember trigger.
   Test Class:      CampaignMemberTriggerTest.cls
   Date                 Version     Author              Summary of Changes 
   -----------          -------     ------------------- -------------------------------------------
   18-April-2018          0.1       Iegor Nechyporenko  Initial
  ------------------------------------------------------------------------------------------------  */
@isTest(SeeAllData = false)
public with sharing class CampaignMemberTriggerTest {	
	/*
	* @describe Create Campaign and Contact which will be used test CampaignMember object
	*/
	@testSetup static void prepareTestData(){
        List<Account> accList = PrepareTestData.PrepareAccounts(1,true,GlobalConstants.CUSTOMER_RECORD_TYPE);
        
        Contact cont= PrepareTestData.getTestContact(accList[0].Id);
        Database.insert(cont);
        
        Campaign Camp= PrepareTestData.getTestCampaign(true);
    
        CampaignMember member = PrepareTestData.getTestCampaignMember(true,camp.Id,cont.Id);
	}
	
    /**
    * @description Returns CampaignMember with authorised / non-authorised status
    * 
    **/
	private static CampaignMember getTestCampaignMember(Boolean isAuthorised) {
        
        String status = isAuthorised ? GlobalConstants.AUTHORISED_MEMBER_STATUS
								  : GlobalConstants.NOT_AUTHORISED_MEMBER_STATUS; 
		CampaignMember cmObj =  [SELECT Id,Status FROM CampaignMember LIMIT 1];
        cmObj.Status= status;
        system.assertEquals(status, cmObj.Status);
        return cmObj;        
    }
	
    /**
    * @description Test to check that user with permission cannot set Authorised status.
    **/
    @isTest private static void testUserHasNoPermissionToAuthoriseCampaignMember() {
        User newUser = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_STANDARD_USER);
        newUser.UserPermissionsMarketingUser  = true;
        Database.insert(newUser);
        System.runAs(newUser) {
    		CampaignMember testCampaignMember = getTestCampaignMember(false);
    		Database.SaveResult insertResult = Database.update(testCampaignMember, false);    		
    		System.assertEquals(false, insertResult.isSuccess());
        }
    }
    
	
    /**
    * @description Test to check that user without permission is able to set Authorised/Not Authorised status.
    **/
    @isTest private static void testUserHasPermissionToAuthoriseCampaignMember() {
    	User newUser = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
        newUser.UserPermissionsMarketingUser  = true;
    	Database.insert(newUser);
    	
    	PermissionSet centralMarketingTeam = [SELECT Id FROM PermissionSet WHERE Name = :GlobalConstants.PERMISSION_SET_NAME LIMIT 1];
    	
    	Database.insert(new PermissionSetAssignment(
    		AssigneeId = newUser.Id,
    		PermissionSetId = centralMarketingTeam.Id
    	));    	
    	System.runAs(newUser) {
    		CampaignMember testCampaignMember = getTestCampaignMember(true);
    		Database.SaveResult insertResult = Database.update(testCampaignMember, false);    		
    		System.assertEquals(true, insertResult.isSuccess());
    	}
    }    
}