/* -----------------------------------------------------------------------------------------------
Name:            CampaignTriggerTest.cls 
Description:     Covers CampaignTrigger and CampaignTriggerHandler 
------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData=true)
private class CampaignTriggerTest {   
    
    /**
    * @description Test for creating campaign and campaignmemberstatuses should match 
    * statuses defined in campaign member's status picklist value
    **/
    @isTest private static void runPositiveTests() {
        User user = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
        system.runAs(user) {
            Test.startTest();
                List<Account> accList = PrepareTestData.PrepareAccounts(1,true,GlobalConstants.CUSTOMER_RECORD_TYPE);
                
                Contact cont= PrepareTestData.getTestContact(accList[0].Id);
                Database.insert(cont);
                
                Campaign Camp= PrepareTestData.getTestCampaign(true);
    
                CampaignMember member = PrepareTestData.getTestCampaignMember(true,camp.Id,cont.Id);
                
                List<CampaignMemberStatus> cmsList = [ SELECT Id,Label,isDefault,
                                                      HasResponded 
                                                      FROM CampaignMemberStatus 
                                                      WHERE CampaignId = :camp.Id
                                                      LIMIT 100];
                                
                List<String> statusList = new List<String>();
                Schema.DescribeFieldResult fieldResult = CampaignMember.Status__c.getDescribe();
                List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
                
                for( Schema.PicklistEntry ple : picklistEntryList) {
                    if(ple.isActive()){
                        statusList.add(ple.getValue());
                    }                
                }           
            Test.stopTest();
            system.assertEquals(statusList.size(), cmsList.size());
        } 
    }
}