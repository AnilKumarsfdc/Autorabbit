/* --------------------------------------------------------------------------------------------------
  Name:            OppSchedulingLightningController.cls 
  Description:     Aura controller of Lightning component which is used to setup Custom Schedule 
  Drawdown for specified Lending Opportuntiy Product
  Test class:      OppSchedulingLightningControllerTest.cls 
  ------------------------------------------------------------------------------------------------ */
public with sharing class OppSchedulingLightningController {

	/** 
	 * @description :Retireives Opportunity Product information with all
	 **/
	@AuraEnabled
	public static Opportunity_Product__c getOpportunityProductWithSchedules(Id opportunityProductId) {
		return[SELECT Id, Facility_Amount__c, Net_Margin_Percentage__c,
		Opportunity__r.CloseDate, (SELECT Id, Drawn_Date__c, Drawn_Amount__c, Estimated_Income__c, Estimated_Income_First_Year__c
		                           FROM Opportunity_Product_Schedules__r
		                           ORDER BY Drawn_Date__c ASC)
		FROM Opportunity_Product__c
		WHERE Id = : opportunityProductId LIMIT 1];
	}



	/** 
	 * @description :Updates all existing Product Scheduling based on existing Scheduling changes Created By: Iegor Nechyporenko
	 **/
	@AuraEnabled
	public static void setupOpportunityProductSchedule(String scheduleToUpsertString, String scheduleToDeleteString) {

		try {
			List<Opportunity_Product_Schedule__c> scheduleToUpsert = null, scheduleToDelete = null;
			if (scheduleToUpsertString != null) {
				scheduleToUpsert = (List<Opportunity_Product_Schedule__c>) JSON.deserialize(scheduleToUpsertString,
				                                                                            List<Opportunity_Product_Schedule__c>.class);
			}
			if (scheduleToDeleteString != null) {
				scheduleToDelete = (List<Opportunity_Product_Schedule__c>) JSON.deserialize(scheduleToDeleteString,
				                                                                            List<Opportunity_Product_Schedule__c>.class);
			}

			if (scheduleToUpsert != null && scheduleToUpsert.size() > 0) {
				upsert scheduleToUpsert;
			}

			if (scheduleToDelete != null && scheduleToDelete.size() > 0) {
				delete scheduleToDelete;
			}

		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}



	}
}