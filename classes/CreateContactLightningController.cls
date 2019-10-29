/* --------------------------------------------------------------------------------------------------
     Name:            CreateContactLightningController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  for converting BDP Contacts to salesforce contact.
	 Test class:      CreateContactLightningControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */

public without sharing class CreateContactLightningController {

	public static final String SEMI_COLON = ';';
	public static final String COMMA = ',';


	/**
	 * @description : Get List of Company for the BDP Contact Selected from the Relationship object  .
	 * 
	 **/
	@AuraEnabled
	public static List<BDP_Contact_Relationship__c> getCompanyList(Id bdpContactId) {
		try {
			Set<Id> companyIdSet = new Set<Id> ();
			List<BDP_Contact_Relationship__c> companylist = new List<BDP_Contact_Relationship__c> ();
			for (BDP_Contact_Relationship__c rel :[SELECT BDP_Company__r.Company__c, BDP_Company__r.Company__r.Name,
			     BDP_Company__c, BDP_Contact__r.First_Name__c, BDP_Contact__r.Last_Name__c, BDP_Contact__r.BDP_Email__c,
			     BDP_Contact__r.Salesforce_Contact__c,
			     BDP_Contact__r.Salesforce_Contact__r.Name
			     FROM BDP_Contact_Relationship__c
			     WHERE BDP_Contact__c = :bdpContactId
			     AND BDP_Company__r.Company__c != null LIMIT 10000]) {
				if (!companyIdSet.contains(rel.BDP_Company__r.Company__c)) {
					companyList.add(rel);
					companyIdSet.add(rel.BDP_Company__r.Company__c);
				}
			}
			return companylist;
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description : Creating string  .
	 * 
	 **/
	private static String setToString(Set<String> stringSet, String separator) {
		return String.join(new List<String> (stringSet), separator);
	}

	/**
	 * @description : Wrapper Class.
	 * 
	 **/
	public with sharing class ContactWrapper {
		@AuraEnabled public Contact conObj {get; set;}
		@AuraEnabled public String errorMessage {get; set;}

		/**
		* @description : Wrapper Constructor.
		* 
		**/
		public ContactWrapper (Contact cont, String errMsg) {
			this.conObj = cont;
			this.errorMessage = errMsg;
		}
	}


	/**
	 * @description : Creates and return Salesforce Contact  .
	 * 
	 **/
	@AuraEnabled
	public static ContactWrapper createSfdcContact(Id bdpContactId, Id companyId, Boolean checkbox, String emailId) {
		Map<String, String> fields = new Map<String, String> ();

		Contact contactToInsert = new Contact();
		contactToInsert.AccountId = companyId;
		contactToInsert.Email = emailId;
		AccountContactRelation accCon;
		String errorMessage = '';

		for (BDP_Contact_Mapping__mdt mtdFeilds :[SELECT BDP_Contact_Field__c, Contact_Field__c from BDP_Contact_Mapping__mdt LIMIT 10000]) {
			fields.put(mtdFeilds.BDP_Contact_Field__c, mtdFeilds.Contact_Field__c);
		}

		String query = 'SELECT Id, ' + setToString(fields.keySet(), COMMA) + ' ' +
		'FROM BDP_Contact__c ' +
		'WHERE Id = \'' + bdpContactId + '\'';

		BDP_Contact__c bdpContact = Database.query(query);
		for (String field : fields.keyset()) {
			String contactField = fields.get(field);

			if (bdpContact.get(field) != null && bdpContact.get(field) != false) {
				contactToInsert.put(contactField, bdpContact.get(field));
			}
		}

		//try {
		//Database.insert(contactToInsert);

		Database.SaveResult sResult = Database.insert(contactToInsert, false);

		if (!sResult.isSuccess()) {
	
			// Insertion failed due to duplicate detected
			for(Database.Error duplicateError : sResult.getErrors()){
				Datacloud.DuplicateResult duplicateResult = 
						  ((Database.DuplicateError)duplicateError).getDuplicateResult();
				errorMessage = duplicateResult.getErrorMessage();
			}
		}

		Id conID = contactToInsert.ID;

		Database.update(new BDP_Contact__c(
		                                   Id = bdpContactId,
		                                   Salesforce_Contact__c = conId
		));

		if (checkbox == true) {
			List<AccountContactRelation> accConRel = new List<AccountContactRelation> ();
			Map<Id, Set<String>> rolesMap = new Map<Id, Set<String>> ();

			AccountContactRelation primaryRelation = null;
			for (AccountContactRelation rel :[SELECT Id, AccountId, ContactId, Roles
			     FROM AccountContactRelation
			     WHERE ContactId = :conId
			     AND AccountId = :companyId LIMIT 10000]) {
				primaryRelation = rel;
			}

			for (BDP_Contact_Relationship__c bdprel :[SELECT BDP_Company__r.Company__c, Role__c
			     FROM BDP_Contact_Relationship__c
			     WHERE BDP_Contact__c = :BdpContactId
			     AND BDP_Company__r.Company__c != null LIMIT 10000]) {
				Id compId = bdprel.BDP_Company__r.Company__c;
				if (!rolesMap.containsKey(compId)) {
					rolesMap.put(compId, new Set<String> ());
				}

				if (bdprel.Role__c != null) {
					rolesMap.get(compId).add(bdprel.Role__c);

				}
			}

			for (ID compId : rolesMap.keySet()) {
				if (compId == companyId) {
					//Populate roles for Direct Relation
					if (primaryRelation != null) {
						if (rolesMap.get(compId) != null && rolesMap.get(compId).size() > 0) {
							primaryRelation.Roles = setToString(rolesMap.get(compId), SEMI_COLON);
						}
						accConRel.add(primaryRelation);
					}
				} else {
					//Populate roles for Indirect Relations
					accCon = new AccountContactRelation();
					accCon.AccountId = compId;
					accCon.ContactId = conID;
					if (rolesMap.get(compId) != null && rolesMap.get(compId).size() > 0) {
						accCon.Roles = setToString(rolesMap.get(compId), SEMI_COLON);
					}
					accConRel.add(accCon);
				}
			}

			if (accConRel.size() > 0) {
				try {
					Database.upsert(accConRel);
				}
				catch(Exception e) {
					throw e;
				}
			}
		}

		return new ContactWrapper(contactToInsert, errorMessage);
	}
}