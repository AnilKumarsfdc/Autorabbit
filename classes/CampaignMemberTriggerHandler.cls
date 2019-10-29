/* -------------------------------------------------------------------------------------------------- 
   Description:     Handler class for Campaign Member Trigger class.
   					Prevets users to update Campaign Member Status to Authorised / Not Authorised,
   					if User don't have relevant Permission
   Test Class:      CampaignMemberTriggerTest.cls
   Date                 Version     Author              Summary of Changes 
   -----------          -------     ------------------- -------------------------------------------
   18-April-2018          0.1       Iegor Nechyporenko  Initial
  ------------------------------------------------------------------------------------------------  */
public with sharing class CampaignMemberTriggerHandler {
	
	/*
	*	@description Method which prevents Campaign Member status to be updated / set, if User don't have relevat Custom Permission
	*   to "Authorise Marketing Event Users"
	*/
	public static void checkAuthorisedMember(List<CampaignMember> newValues, Map<Id, CampaignMember> oldValuesMap){
        try{
            if (!hasUserPermissionToAuthoriseCampaignMembers()) {
                String oldStatus, currentStatus;
                for (CampaignMember marketingEventMember : newValues) {
                    currentStatus = marketingEventMember.Status;
                    oldStatus = (!oldValuesMap.containsKey(marketingEventMember.Id)) ? null 
                        : oldValuesMap.get(marketingEventMember.Id).Status;
                    
                    if ((GlobalConstants.AUTHORISED_MEMBER_STATUS.equalsIgnoreCase(currentStatus) 
                         || GlobalConstants.NOT_AUTHORISED_MEMBER_STATUS.equalsIgnoreCase(currentStatus)) &&
                        oldStatus != currentStatus) {
                            marketingEventMember.Status.addError(GlobalConstants.NO_PERMISSION_TO_AUTHORISE_ERROR_MESSAGE);
                        }
                }
            }
        }catch(Exception exc){
            throw exc;
        }
    }    
	
	/*
	* @description Method returns if current user has Custom Permission to "Authorise Marketing Event Users"
	*/
	private static Boolean hasUserPermissionToAuthoriseCampaignMembers() {
		CustomPermission authoriseCustomPermission = [SELECT Id, DeveloperName from CustomPermission 
													  WHERE DeveloperName = :GlobalConstants.AUTHORISE_PERMISSION_NAME
													  LIMIT 1];
													   
		List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
				FROM SetupEntityAccess
				WHERE SetupEntityId = :authoriseCustomPermission.Id 
				  AND ParentId IN (SELECT PermissionSetId 
   							FROM PermissionSetAssignment
   							WHERE AssigneeId = :UserInfo.getUserId())
   			    LIMIT 1
   		];
   		
   		return (setupEntities.size() > 0);			
	}
}