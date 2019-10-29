/* --------------------------------------------------------------------------------------------------
     Name:            SalesforceContactController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  for updating BDP Contact with related Salesforce Contacts.
	 Test class:      SalesforceContactControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public without sharing class SalesforceContactController  {

	/**
	 * @description : Get List of Contacts for the BDP Contact Selected from the Relationship object  .
	 * 
	 **/
	@AuraEnabled
	public static List<AccountContactRelation> getContactList(Id bdpContactId) {
		try {
			Set<Id> companyIdSet = new Set<Id> ();
			List<AccountContactRelation> contactList = new List<AccountContactRelation>();
			for (BDP_Contact_Relationship__c rel :[SELECT BDP_Company__r.Company__c, BDP_Company__r.Company__r.Name,
			     BDP_Company__c, BDP_Contact__r.First_Name__c, BDP_Contact__r.Last_Name__c,
			     BDP_Contact__r.Salesforce_Contact__c,
			     BDP_Contact__r.Salesforce_Contact__r.Name
			     FROM BDP_Contact_Relationship__c
			     WHERE BDP_Contact__c = :bdpContactId
			     AND BDP_Company__r.Company__c != null LIMIT 10000]) {
				if (!companyIdSet.contains(rel.BDP_Company__r.Company__c)) {
					companyIdSet.add(rel.BDP_Company__r.Company__c);
				}
			}

			if (!companyIdSet.isEmpty()) {
				contactList = [SELECT ContactId, Contact.Name, AccountId, Account.Name
							   FROM AccountContactRelation
							   WHERE AccountId IN :companyIdSet LIMIT 10000];
			}

			return contactList;
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description : Check for Salesforce Contact on the BDP Contact record.
	 * 
	 **/
	@AuraEnabled
	public static Contact getSalesforceContact(Id bdpContactId) {
		try {
			Contact salesforceContact = null;
			for (BDP_Contact__c bdpContact : [SELECT Id, Salesforce_Contact__c
											  FROM BDP_Contact__c
										      WHERE Id =: bdpContactId LIMIT 1]) {
				if (bdpContact.Salesforce_Contact__c != null) {
					salesforceContact = [SELECT Id, Name
										 FROM Contact
										 WHERE Id =:bdpContact.Salesforce_Contact__c LIMIT 1];
				}			 
			}
			return salesforceContact;
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description Updates Salesforce Contact on BDP Contact
	 * 
	 **/
	@AuraEnabled
	public static void updateSalesforceContact(string contactToUpdateString) {
		List<BDP_Contact__c> bdpContactToUpdate = null;

		if (contactToUpdateString != null) {
			bdpContactToUpdate = (List<BDP_Contact__c>) JSON.deserialize(contactToUpdateString,
			                                                   List<BDP_Contact__c>.class);
		}

		if (bdpContactToUpdate != null && bdpContactToUpdate.size() > 0) {
			try {
				Database.update(bdpContactToUpdate);
			}
			catch(AuraHandledException e) {
				throw e;
			}
		}
	}
}