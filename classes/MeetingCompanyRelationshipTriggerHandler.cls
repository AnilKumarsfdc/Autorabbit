/* --------------------------------------------------------------------------------------------------
     Name:            MeetingCompanyRelionshipTriggerHandler.cls 
     Description:     Handler class for MeetingCompanyRelTrigger
     Test class:      MeetingCompanyRelionshipTest.cls 
    ------------------------------------------------------------------------------------------------ */
public class MeetingCompanyRelationshipTriggerHandler {
	/**
	 * @description This method is used to process Before Insert Functionalities  .
	 * 
	 **/
	public static void processAfterInsert(List<Meeting_Company_Relation__c> meetingList) {
		try {
			updateCompanyLastContactedDate(meetingList);
		}
		catch(Exception e) {
			throw e;
		}
	}
    
    /**
	 * @description update company last contacted date after creationg meeting company relationship  .
	 * 
	 **/
	public static void updateCompanyLastContactedDate(List<Meeting_Company_Relation__c> mList) {
		try { 
            Set<Id> accountIdsSet = new Set<Id>();
            Set<Id> meetingCompRelIds = new Set<Id>();
            for(Meeting_Company_Relation__c mcrObj : mList){
                accountIdsSet.add(mcrObj.Company__c);
                meetingCompRelIds.add(mcrObj.Id);
            }          
            Map<Id,Account> mapIdToCompany = new Map<Id,Account>([SELECT Id,Last_Contacted_Date__c 
                                                                 FROM Account 
                                                                 WHERE Id IN : accountIdsSet LIMIT 50000]);
           
            for(Meeting_Company_Relation__c mcrObj : [SELECT Id,Company__c,Meeting__r.Start_DateTime__c,
                                                             Company__r.Last_Contacted_Date__c
                                                      FROM Meeting_Company_Relation__c 
                                                      WHERE ID IN : meetingCompRelIds LIMIT 50000]){
                    
                    if(mcrObj.Company__r.Last_Contacted_Date__c < mcrObj.Meeting__r.Start_DateTime__c ||
                       mcrObj.Company__r.Last_Contacted_Date__c == null){                            
                            mapIdToCompany.get(mcrObj.Company__c).Last_Contacted_Date__c = Date.valueOf(mcrObj.Meeting__r.Start_DateTime__c);                                 
                    } 
            }
           
            if(mapIdToCompany.size()>0){                
                Database.update(mapIdToCompany.values());
            }
		}
		catch(Exception e) {
			throw e;
		}
	}
}