/* --------------------------------------------------------------------------------------------------
     Name:            OpportunityProductTriggerHandlerTest.cls 
     Description:     Test class which checks functionality of Opportunity Product Trigger,
  					  in particular it recalculate Fees for Products, when Term in Months is updated
    ------------------------------------------------------------------------------------------------ */
@isTest
private class OpportunityProductTriggerHandlerTest {
	private static final String TEST_RECORD_TYPE = 'Lending';
	
	/*
	* @description Check fee recalculation after Fee Update
	*/
    private static testMethod void checkIncomeRecalculationOnTermInLoan() {
		User currentUser = new User(Id = UserInfo.getUserId());
		System.runAs(currentUser){
			Account testAccount = PrepareTestData.getDefaultAccount();
			Database.insert(testAccount);
			
			Opportunity oppRecord = PrepareTestData.getOpportunityData(
				TEST_RECORD_TYPE, testAccount.Id
			);				
			Database.insert(oppRecord);
			
			Opportunity_Product__c oppProduct = PrepareTestData.getOpportunityProduct(
				oppRecord.Id, TEST_RECORD_TYPE
			);
			oppProduct.Facility_Amount__c = PrepareTestData.randomInt(10000);
			oppProduct.Gross_Margin__c = 25;
			oppProduct.TP_Rate__c = 5;
			oppProduct.Term_In_Months__c = 12;
			Database.insert(oppProduct);
			
			Opportunity_Product__c feeProduct = PrepareTestData.getOpportunityProduct(
				oppRecord.Id, GlobalConstants.OPP_PRODUCT_FEE_RECORD_TYPE
			);
			feeProduct.Fee_Amount__c = PrepareTestData.randomInt(100);
			Database.update(new Product2(
				Id = feeProduct.Product__c,
				Amortised_Income__c = true
			));
			Database.insert(feeProduct);			
			
			Test.startTest();
			Database.update(new Opportunity_Product__c(Id = oppProduct.Id, Term_In_Months__c = 6));
			Test.stopTest();
			
			Opportunity_Product__c resultFeeProduct = [SELECT Estimated_Income__c
				FROM Opportunity_Product__c
				WHERE Id = :feeProduct.Id];
			System.assertEquals(feeProduct.Fee_Amount__c * 2, resultFeeProduct.Estimated_Income__c);
		}   	
    }
}