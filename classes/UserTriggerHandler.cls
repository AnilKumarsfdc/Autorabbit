/* --------------------------------------------------------------------------------------------------
     Name:            UserTriggerHandler.cls 
     Description:     Trigger handler class, responsible on assigning user to perticular chatter group
                      on basis of user's department,division, region, segment etc.
     Test class:      UserTriggerHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class UserTriggerHandler {
    /**
     * @description onAfterInsert method which runs through the list of user to assign it to chatter group
     **/
    public static void onAfterInsert(Map<Id, User> newValues){ 
        try{
        	if (!System.isBatch() && !System.isFuture() && !System.isScheduled()) {
	            assignUserToChatterGroup(newValues.keySet());
        	}
        }catch(Exception ex){
            throw ex;
        }
    }
    /**
     * @description onAfterUpdate method which runs through the list of user to update/delete it to/from chatter group
     **/
    public static void onAfterUpdate(Set<Id> updatedUserIds){ 
        try{
        	if (!System.isBatch() && !System.isFuture() && !System.isScheduled()) {
            	assignUserToChatterGroup(updatedUserIds);
        	}
        }catch(Exception ex){
            throw ex;
        }
    }    
    /**
     * @description this method adds user to specific chatter group based on custom setting configuration 
     **/
    @future    
    private static void assignUserToChatterGroup(Set<Id> userIds) {       
        
        List<User> userList = [SELECT Id,Division,Region__c,Segment__c,Department 
                                  FROM User
                                  WHERE Id 
                                  IN : userIds];        
        Map<Id,CollaborationGroupMember> existingMemberships = new Map<Id,CollaborationGroupMember>(
            														[ SELECT ID,collaborationGroupId,collaborationGroup.OwnerId,MemberId 
                                                            			 FROM CollaborationGroupMember
                                                            			 WHERE MemberId IN : userIds]);
        
        Map<String, Chatter_Group_Assignments__c> allRecords = Chatter_Group_Assignments__c.getAll(); //get everything from the SFCD cache
        
        
        Map<Id, CollaborationGroupMember> membershipMap; //Key should be group Id
        Map<Id, Map<Id, CollaborationGroupMember>> membershipMapOfMap = new  Map<Id, Map<Id, CollaborationGroupMember>>(); //First Id is User Id, second Id, is GroupId
        Map<Id,Id> groupOwnershipMap = new Map<Id,Id>();
        for(User usr : userList){
            membershipMap = new Map<Id, CollaborationGroupMember>(); 
            for(CollaborationGroupMember gm : existingMemberships.values()){
                if((usr.Id).equals(gm.MemberId)){                   
                   membershipMap.put(gm.CollaborationGroupId,gm);
                   membershipMapOfMap.put(usr.Id,membershipMap);
                }
            }
        }
        
        List<CollaborationGroupMember> toBeAddedGM =new List<CollaborationGroupMember>(); 
        List<CollaborationGroupMember> toBeDeletedGM=new List<CollaborationGroupMember>();
        
        for(User usr : userList){
           
            Map<Id, CollaborationGroupMember> userGroupMap = membershipMapOfMap.get(usr.Id)==null 
                															? new Map<Id,CollaborationGroupMember>() 
                															:  membershipMapOfMap.get(usr.Id) ; //Just be carefull WITH NULL values
           
            for(Chatter_Group_Assignments__c cga :allRecords.values()){  
                
                
                If((String.isBlank(cga.Department__c) || cga.Department__c.equalsIgnoreCase(usr.Department))
                   &&(String.isBlank(cga.Division__c) || cga.Division__c.equalsIgnoreCase(usr.Division))
                   && (String.isBlank(cga.Region__c)  || cga.Region__c.equalsIgnoreCase(usr.Region__c))                 
                   && (String.isBlank(cga.Segment__c) || cga.Segment__c.equalsIgnoreCase(usr.Segment__c))) {   
                      
                       if (!userGroupMap.containsKey(cga.Chatter_Group_Id__c)){
                           CollaborationGroupMember gm=new CollaborationGroupMember();
                           gm.collaborationGroupId=cga.Chatter_Group_Id__c;
                           gm.memberId=usr.Id;
                           gm.NotificationFrequency=Label.CHATTER_NOTIFICATION_FREQUENCY;
                           toBeAddedGM.add(gm);
                       }
               } else {
                   if (userGroupMap.containsKey(cga.Chatter_Group_Id__c) && !(userGroupMap.get(cga.Chatter_Group_Id__c).collaborationGroup.OwnerId).equals(usr.Id)){                      
                       	toBeDeletedGM.add(userGroupMap.get(cga.Chatter_Group_Id__c));
                   }                  
               }
            }
        }
        try{
            if(toBeAddedGM.size()>0){               
                Database.insert(toBeAddedGM,false);            
            }
            if(toBeDeletedGM.size()>0){                 
                Database.delete(toBeDeletedGM,false);            
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}