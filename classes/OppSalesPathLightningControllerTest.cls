/*--------------------------------------------------------------------------------------------------
	Name:      OppSalesPathLightningControllerTest.cls
	Description:   Test Class for Aura controller OpportunitySalesPathLightningController
------------------------------------------------------------------------------------------------ */
@isTest
private class OppSalesPathLightningControllerTest {
	private static final String TEST_RECORD_TYPE = 'Lending';
	private static final String CLOSED_LOST = 'Closed Lost';
	private static final String TEST_LOST_REASON = 'Declined';
	private static final String TEST_LEAD_SOURCE = 'Other';


	/** 
	 * @description : Check Result when Opportunity don't have Primary Product
	 **/
	private static testMethod void testOpportunityDataWithoutPrimaryProduct() {
		try {
			System.runAs(PrepareTestData.getRunningUser()) {

				Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
				Database.insert(testOpportunity);

				Id productRecordTypeId = PrepareTestData.getRecordTypeId(Schema.SObjectType.Opportunity_Product__c,
				                                                         TEST_RECORD_TYPE);

				Test.startTest();
				OpportunitySalesPathLightningController.SalesPathResponse response;
				response = OpportunitySalesPathLightningController.getSalesPathInformation(testOpportunity.Id);
				Test.stopTest();

				//Test opportunity Infomration
				System.assertEquals(testOpportunity.Id, response.opportunity.Id);
				System.assertEquals(TEST_RECORD_TYPE, response.opportunity.RecordType.Name);
				//Test opportuinty Product Information
				System.assertEquals(productRecordTypeId, response.opportunityProduct.RecordTypeId);
				System.assertEquals(testOpportunity.Id, response.opportunityProduct.Opportunity__c);
				System.assertEquals(null, response.opportunityProduct.Id);
			}
		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}
	}


	/** 
	 * @description : Test That Oportunity has been returned With Primary Product
	 **/
	private static testMethod void testOpportunityDataWithPrimaryProduct() {
		System.runAs(PrepareTestData.getRunningUser()) {

			Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
			Database.insert(testOpportunity);

			Opportunity_Product__c primaryProduct = PrepareTestData.getOpportunityProduct(testOpportunity.Id, TEST_RECORD_TYPE);
			Database.insert(primaryProduct);

			Id productRecordTypeId = PrepareTestData.getRecordTypeId(Schema.SObjectType.Opportunity_Product__c,
			                                                         TEST_RECORD_TYPE);

			Test.startTest();
			OpportunitySalesPathLightningController.SalesPathResponse response = null;
			response = OpportunitySalesPathLightningController.getSalesPathInformation(testOpportunity.Id);
			Test.stopTest();


			//Test opportuinty Product Information
			System.assertEquals(testOpportunity.Id, response.opportunityProduct.Opportunity__c);
			System.assertEquals(primaryProduct.Id, response.opportunityProduct.Id);
			//Test Product List Information
			System.assert(response.productList.size() > 0, 'No products has been found');
			Product2 availableProduct = response.productList.get(0);
			System.assertEquals(primaryProduct.Product__c, availableProduct.Id);
		}
	}


	/** 
	 * @description :Test that Opportunity could be successfully closed lost Lightning Controller methods
	 **/
	private static testMethod void testOpportunityCloseLostFunctionality() {
		System.runAs(PrepareTestData.getRunningUser()) {
			Opportunity testOpportunity = PrepareTestData.getOpportunityData(TEST_RECORD_TYPE, null);
			Database.insert(testOpportunity);

			Opportunity_Product__c primaryProduct = PrepareTestData.getOpportunityProduct(testOpportunity.Id, TEST_RECORD_TYPE);
			Database.insert(primaryProduct);

			Test.startTest();
			testOpportunity.Lost_Reason__c = TEST_LOST_REASON;
			testOpportunity.CloseDate = Date.today();
			testOpportunity.LeadSource = TEST_LEAD_SOURCE;
			OpportunityTriggerHandler.DISABLE_EXECUTION = true;
			OpportunitySalesPathLightningController.updateOpportunityData(
			                                                              JSON.serialize(testOpportunity),
			                                                              JSON.serialize(primaryProduct)
			);
			OpportunitySalesPathLightningController.moveOpportunityToStage(testOpportunity.Id, CLOSED_LOST, null);
			Test.stopTest();

			OpportunitySalesPathLightningController.UpdateResponse updateResult = null;
			updateResult = OpportunitySalesPathLightningController.getOpportunityUpdates(testOpportunity.Id);

			//Test response result
			System.assertEquals(CLOSED_LOST, updateResult.opportunity.StageName);
			System.assertEquals(TEST_LOST_REASON, updateResult.opportunity.Lost_Reason__c);
		}
	}
}