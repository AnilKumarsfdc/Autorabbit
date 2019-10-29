@isTest
private class OpportunityTriggerHandlerTest {
    private static final String TEST_RECORD_TYPE = 'Lending';
    private static final String CLOSED_LOST = 'Closed Lost';
    private static final String CLOSED_WON = 'Closed Won';
    private static final String TEST_LOST_REASON = 'Declined';
    private static final String PRE_CREDIT = 'Pre-Credit';
	private static final String TEST_LEAD_SOURCE = 'Other';
    
	/** 
	 * @description : Test Setup Method to create Opportunity
	 **/
    private static testMethod void testOpportunityClosedLostFail() {    
        Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
        Database.insert(testOpportunity);
        
        Test.startTest();
        testOpportunity.StageName = CLOSED_LOST;
        Database.UpsertResult result = Database.upsert(testOpportunity, false);
        Test.stopTest();
        
        System.assert(!result.isSuccess(), 'Opportunity should fail because of Closed Lost not populated');     
    }   
    
	/** 
	 * @description : Test Setup Method to create Opportunity
	 **/
    private static testMethod void testOpportunityClosedLostSuccess() {     
        Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
        Database.insert(testOpportunity);
        
        Test.startTest();
        testOpportunity.StageName = CLOSED_LOST;
        testOpportunity.Lost_Reason__c = TEST_LOST_REASON;
        testOpportunity.CloseDate = Date.today();
        testOpportunity.Lost_Comments__c = TEST_LOST_REASON;
		testOpportunity.LeadSource = TEST_LEAD_SOURCE;
        Database.UpsertResult result = Database.upsert(testOpportunity, false);
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'Opportunity should be successfully updated' + 
                      ' as only required Lost Reason is populated. Errors: ' + result.getErrors());     
    }  
     
	/** 
	 * @description : Test Setup Method to create Opportunity
	 **/   
    private static testMethod void testOpportunityJumpFail() {      
        Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
        Database.insert(testOpportunity);
        
        Test.startTest();
        testOpportunity.StageName = CLOSED_WON;
        Database.UpsertResult result = Database.upsert(testOpportunity, false);
        Test.stopTest();
        
        System.assert(!result.isSuccess(), 'Triggger shouldn\'t allow jumping ahead between stages');       
    }
    
	/** 
	 * @description : Test Setup Method to create Opportunity
	 **/        
    private static testMethod void testOpportunityMoveWithoutProductFail() {    
        Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
        Database.insert(testOpportunity);
        
        Test.startTest();
        testOpportunity.StageName = PRE_CREDIT;
        Database.UpsertResult result = Database.upsert(testOpportunity, false);
        Test.stopTest();
        
        System.assert(!result.isSuccess(), 'Triggger shouldn\'t allow moving to next stage without product specified');     
    } 
    
	/** 
	 * @description : Test Setup Method to create Opportunity
	 **/        
    private static testMethod void testOpportunityMoveNoRequiredFieldsFail() {      
        Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
        Database.insert(testOpportunity);
        
        Opportunity_Product__c primaryProduct = PrepareTestData.getOpportunityProduct(testOpportunity.Id, TEST_RECORD_TYPE);
        Database.insert(primaryProduct);
        
        Test.startTest();
        testOpportunity.StageName = PRE_CREDIT;
        Database.UpsertResult result = Database.upsert(testOpportunity, false);
        Test.stopTest();
        
        System.assert(!result.isSuccess(), 'Triggger shouldn\'t allow moving to next stage without required fields specified');     
    }
}