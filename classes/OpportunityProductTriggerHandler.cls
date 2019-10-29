/* --------------------------------------------------------------------------------------------------
     Name:            OpportunityProductTriggerHandler.cls 
     Description:     Trigger handler class, responsible for population Primary Product Lookup of Opportunity
  					  and also recalculation Fee Estimation Income, when Term In Months is changed
  	 Test class:      OpportunityProductTriggerHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class OpportunityProductTriggerHandler {
	/**
	* @desction Actions which should be executen after Opportunity Product is created
	**/
    public static void onAfterInsert(List<Opportunity_Product__c> opportunityProductList) {
    	setOpportunityPrimaryProduct(opportunityProductList);
    }
    
	/**
	* @desction Actions which should be executen after Opportunity Product is updated
	**/
    public static void onAfterUpdate(List<Opportunity_Product__c> opportunityProductList, 
    								 Map<Id, Opportunity_Product__c> oldValues) {
    	Set<Id> opportunitiesToFix = new Set<Id>();
    	Opportunity_Product__c oldValue = null;
    	for (Opportunity_Product__c newValue : opportunityProductList) {
    		if (newValue.Primary__c == true) {
    			oldValue = oldValues.get(newValue.Id);
    			if (oldValue.Term_In_Months__c != newValue.Term_In_Months__c) {
    				opportunitiesToFix.add(newValue.Opportunity__c);
    			}
    		}
    	}
    	
    	if (opportunitiesToFix.size() > 0) {
    		fixFeesForOpportunities(opportunitiesToFix);	
    	}
    }
    
	/**
	* @desction Sets Primary Product Lookup Value for selected Opportunities
	**/
    private static void setOpportunityPrimaryProduct(List<Opportunity_Product__c> opportunityProductList) {
    	List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    	Set<Id> opportunityIdToFix = new Set<Id>();
    	
    	for (Opportunity_Product__c opportunityProduct : opportunityProductList) {
    		if (opportunityProduct.Primary__c == true) {
    			opportunitiesToUpdate.add(
    				new Opportunity(
    					Id = opportunityProduct.Opportunity__c,
    					Primary_Product_Lookup__c = opportunityProduct.Id
    				)
    			);
    			
    			if (opportunityProduct.Term_In_Months__c != null){
    				opportunityIdToFix.add(opportunityProduct.Opportunity__c);
    			}
    		}
    	}
    	
    	if (opportunitiesToUpdate.size() > 0){
    		Database.update(opportunitiesToUpdate);
    	}
    	
    	if (opportunityIdToFix.size() > 0) {
    		fixFeesForOpportunities(opportunityIdToFix);
    	}
    }
    
	/**
	* @desction Update Fee's when Term in Month has been changed on primary product for selected opportunities
	**/    
    private static void fixFeesForOpportunities(Set<Id> opportunityIdSet) {
    	List<Opportunity_Product__c> feesToUpdate = new List<Opportunity_Product__c>();
    	
    	List<Opportunity_Product__c> feeList = [SELECT Id, Estimated_Income__c, Fee_Amount__c,
    		Estimated_Income_Formula__c, Estimated_Income_First_Year__c, Estimated_Income_First_Year_Copy__c
    		FROM Opportunity_Product__c
    		WHERE Primary__c = false
    		AND Amortised_Income__c = true
    		AND Opportunity__c IN :opportunityIdSet
    		LIMIT :GlobalConstants.MAX_QUERY_LIMIT
    	];
    	
    	for (Opportunity_Product__c feeProduct : feeList) {
    		if (feeProduct.Estimated_Income_Formula__c != feeProduct.Estimated_Income__c ||
    			feeProduct.Estimated_Income_First_Year__c != feeProduct.Estimated_Income_First_Year_Copy__c) {
    			feeProduct.Estimated_Income__c = feeProduct.Estimated_Income_Formula__c;
    			feeProduct.Estimated_Income_First_Year_Copy__c = feeProduct.Estimated_Income_First_Year__c;
    			feesToUpdate.add(feeProduct);
    		}
    	}
    	
    	if (feesToUpdate.size() > 0) {
    		Database.update(feesToUpdate);
    	}
    }
}