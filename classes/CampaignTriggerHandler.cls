/* -----------------------------------------------------------------------------------------------
     Name:            CampaignTriggerHandler.cls 
     Description:     Creates CampaignMemberStatus records with values from CampaignMember Status  
					  active Picklist values 
	Test Class: 	  CampaignTriggerTest.cls
	Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   26-March-2018          0.1         Vijay Sonawane         Initial
  ------------------------------------------------------------------------------------------------  */
	public with sharing class CampaignTriggerHandler {
        private static string errorMessage;
        private final static string DEFAULT_STATUS = 'Nominated';
        private final static string RESPONDED_STATUS = 'Accepted';
        private final static String TEMP_PREFFIX = '_';
        
        /**
        * @desction Actions which should be executen after Campaign is created
        **/
        public static void onAfterInsert(List<Campaign> campaignList) {
            try{
                createCampaignMemberStatusRecords(campaignList);
            }catch(Exception ex){
                errorMessage = ex.getMessage();
                throw ex;
            }
        }
    
        /**
        * @desction creates campaingMemberStatus records
        **/
        private static void createCampaignMemberStatusRecords(List<Campaign> campaignList) {
            
            List<CampaignMemberStatus> campaignMemberStatusList = new List<CampaignMemberStatus>();
           
            List<String> statusList = getActiveStatusPicklistValues();       
            List<CampaignMemberStatus> campaignMemberStatusUpdateList = [Select Id,
                                                                         Label,CampaignId,SortOrder,isDefault,HasResponded 
                                                                         FROM CampaignMemberStatus
                                                                         WHERE CampaignId IN : campaignList LIMIT 10000];
           for(CampaignMemberStatus cmsObj : campaignMemberStatusUpdateList){
                if(cmsObj.IsDefault == true){
                    cmsObj.Label = TEMP_PREFFIX + DEFAULT_STATUS;                    
                }
                if(cmsObj.HasResponded == true){
                    cmsObj.Label = TEMP_PREFFIX + RESPONDED_STATUS;
                }
                
                campaignMemberStatusList.add(new CampaignMemberStatus(
                	Id = cmsObj.Id,
                	Label = cmsObj.Label
                ));
            }

            for(Campaign cmp : campaignList) {   
            	Integer currentSortOrderIndex = 3;        
                for(String status : statusList){ 
                    if( ! DEFAULT_STATUS.equals(Status) && ! RESPONDED_STATUS.equals(status)) {
                        CampaignMemberStatus cmsObj = new  CampaignMemberStatus();
                        cmsObj.CampaignId = cmp.Id;
                        cmsObj.Label = TEMP_PREFFIX + status;       
                        cmsObj.SortOrder = currentSortOrderIndex;
                        currentSortOrderIndex += 1;
                        campaignMemberStatusList.add(cmsObj);
                     }
                } 
            }
                        
            if (!campaignMemberStatusList.isEmpty()){
                Database.upsert(campaignMemberStatusList);
            } 
            
            
            List<CampaignMemberStatus> unsetRespondedFlagList = new List<CampaignMemberStatus>();
            campaignMemberStatusUpdateList = [SELECT Id, Label, SortOrder,HasResponded 
                                              FROM CampaignMemberStatus
                                              WHERE CampaignId IN : campaignList 
                                              ORDER BY SortOrder ASC
                                              LIMIT 10000];                                  
                                              
            for (CampaignMemberStatus memberStatus : campaignMemberStatusUpdateList) {
            	memberStatus.Label = statusList.get(memberStatus.SortOrder - 1);          	
            	if (memberStatus.Label == RESPONDED_STATUS) {
            		memberStatus.HasResponded = true;
            	} else if (memberStatus.HasResponded) {
            		unsetRespondedFlagList.add(new CampaignMemberStatus(Id = memberStatus.Id, HasResponded = false));
            	}
            }			            
            Database.update(campaignMemberStatusUpdateList);
            
            if (unsetRespondedFlagList.size() > 0) {        	
	            Database.update(unsetRespondedFlagList, false);
            }
        }
        
        /**
        * @desction populates active picklist values from  campaingMember object's status field
        **/
        private static List<String> getActiveStatusPicklistValues() {           
            List<String> statusList = new List<String>();
            
            Schema.DescribeFieldResult fieldResult = CampaignMember.Status__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry ple : picklistEntryList) {
                if(ple.isActive()){
                    statusList.add(ple.getValue());
            	}                
            }       
            return statusList;    	
        }  
}