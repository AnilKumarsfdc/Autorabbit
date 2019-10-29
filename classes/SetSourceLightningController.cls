/* --------------------------------------------------------------------------------------------------
     Name:            SetSourceLightningController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  of Setting up Source information on Company and Opportunity
	 Test class:      SetSourceLightningControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class SetSourceLightningController {

	/**
	 * @description Updates Source Information on Company
	 * 
	 **/
	@AuraEnabled
	public static void setupAccountSource(string sourceToUpdateString) {
		List<Account> accountToUpdate = null;

		if (sourceToUpdateString != null) {
			accountToUpdate = (List<Account>) JSON.deserialize(sourceToUpdateString,
			                                                   List<Account>.class);
		}

		if (accountToUpdate != null && accountToUpdate.size() > 0) {
			try {
				Database.update(accountToUpdate);
			}
			catch(AuraHandledException exc) {
				throw exc;
			}
		}
	}
    
    /**
	 * @description checks account record Type
	 * 
	 **/
	@AuraEnabled
	public static String getAccountRecordType(ID accId) {
		String accountRecordType = null;
        try {
         	accountRecordType = [SELECT Id, RecordType.Name 
                                 FROM Account 
                                 WHERE Id =: accId 
                                 LIMIT 1].RecordType.Name;
        } catch(AuraHandledException exc) {
            throw exc;
        }
		return accountRecordType;
	}
	/**
	 * @description Updates Source Information on Opportunity
	 * 
	 **/
	@AuraEnabled
	public static void setupOpportunitySource(string sourceToUpdateString) {
		List<Opportunity> opportunityToUpdate = null;
		if (sourceToUpdateString != null) {
			opportunityToUpdate = (List<Opportunity>) JSON.deserialize(sourceToUpdateString,
			                                                           List<Opportunity>.class);
		}

		if (opportunityToUpdate != null && opportunityToUpdate.size() > 0) {
			Database.update(opportunityToUpdate);
		}
	}
   
}