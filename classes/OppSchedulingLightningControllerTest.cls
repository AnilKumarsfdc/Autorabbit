/* --------------------------------------------------------------------------------------------------
   Name:            OppSchedulingLightningControllerTest.cls 
   Description:     Test Class for Aura controller OppSchedulingLightningController    
  ------------------------------------------------------------------------------------------------ */
@isTest
private class OppSchedulingLightningControllerTest {
  	/** 
	* @description : Setup onboarding Process for the Project Created By: Iegor Nechyporenko
	**/
    private static testMethod void runPositiveTests() {
      System.runAs(PrepareTestData.getRunningUser()) {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> opportunityRecordTypeInfo = oppSchema.getRecordTypeInfosByName();
        
        Schema.DescribeSObjectResult oppProdSchema = Schema.SObjectType.Opportunity_Product__c; 
        Map<String,Schema.RecordTypeInfo> opportunityProductRecordTypeInfo = oppProdSchema.getRecordTypeInfosByName();
        
        Account acct = PrepareTestData.getDefaultAccount();
        Database.insert(acct);
        
        Opportunity oppty = new Opportunity(
        	Name='testLendingOpportunity', 
        	RecordTypeId= opportunityRecordTypeInfo.get('Lending').getRecordTypeId(), 
        	AccountId = acct.Id, StageName ='New Opportunity', 
        	CloseDate = System.today()
        );
        Database.insert(oppty);
        
        Opportunity_Product__c opptyProd = new Opportunity_Product__c(
        	Facility_Amount__c = 1000, 
        	Loan_Type_Percentage_New_Money__c = 1, 
        	Net_Margin_Percentage__c = 2, 
        	Opportunity__c = oppty.Id, 
        	RecordTypeId= opportunityProductRecordTypeInfo.get('Lending').getRecordTypeId(), 
        	Term_In_Months__c = 2
        );
        Database.insert(opptyProd);
        
        Opportunity_Product_Schedule__c opptyProdSched = new Opportunity_Product_Schedule__c(
        	Opportunity_Product__c = opptyProd.Id, 
        	Drawn_Date__c = System.today(), 
        	Drawn_Amount__c = 1000, 
        	Estimated_Income_First_Year__c= 1000
        );
        Database.insert(opptyProdSched);
        
        list<Opportunity_Product_Schedule__c> listOpptyProdSched = new list<Opportunity_Product_Schedule__c>{opptyProdSched};
        String scheduleToUpsertString = JSON.serialize(listOpptyProdSched);
        
        Test.startTest();
        Opportunity_Product__c resultProduct = OppSchedulingLightningController.getOpportunityProductWithSchedules(opptyProd.Id);
        OppSchedulingLightningController.setupOpportunityProductSchedule(scheduleToUpsertString, scheduleToUpsertString);
        Test.stopTest();
            
        System.assertEquals(listOpptyProdSched.size(), resultProduct.Opportunity_Product_Schedules__r.size());
      }
    }
}