/* --------------------------------------------------------------------------------------------------
Name:            ObfuscationProcessor.cls 
Description:     Class which executes Obscuration functionality for BDP Contact object
Test class:      ObfuscationProcessorTest.cls 
------------------------------------------------------------------------------------------------ */
global with sharing class BDPContactObfuscationProcessor extends ObfuscationProcessor {
	@TestVisible	
	private final static String SF_CONTACT_LOOKUP = 'Salesforce_Contact__c';
	private final static String F_NUMBER_FIELD = 'F_Number__c';
	
//	global Map<Id, Set<Id>> bdpContactAssignmentMap;
	global Set<Id> sfContactsToObfuscate;
	global Set<Id> sfContactsToCheck;
	global Map<Id, Id> newSfContactMapping;
	private static Boolean bdpObscurationIsInProgress = false;
	
	/*
	*@description Public constructor class
	*/
    public BDPContactObfuscationProcessor() {
        super(BDP_Contact__c.sObjectType);
        sfContactsToCheck = new Set<Id>();
        sfContactsToObfuscate = new Set<Id>();
        newSfContactMapping = new Map<Id, Id>();
    }
    
    /*
    *@describe Extended execute method. It check information for all obscured BDP Contacts to recognise for which Salesforce contact
    *they are related
    */
    global virtual override void execute(Database.BatchableContext BC, List<sObject> scopeList) {
    	bdpObscurationIsInProgress = true;
    	super.execute(BC, scopeList);
    	
    	for (sObject scopeObject : scopeList) {
    		Id sfContactId = (Id)scopeObject.get(SF_CONTACT_LOOKUP);
    		if (sfContactId != null) {
    			sfContactsToCheck.add(sfContactId);
    			if (transferedRecordsIdMap.get(scopeObject.Id) != null) {
    				newSfContactMapping.put(transferedRecordsIdMap.get(scopeObject.Id), sfContactId);
    			}
    		}
    	}
    	
    	bdpObscurationIsInProgress = false;
    }    
    
    /*
    *@description Extended getObscuredClone method, which sets Obscured BDP Contact name value of F Number
    */
    protected override sObject getObscuredClone(sObject origin) {
		BDP_Contact__c obscuredClone = (BDP_Contact__c)super.getObscuredClone(origin);
		String fNumber = (String)origin.get(F_NUMBER_FIELD);
		if (fNumber != null) {
			obscuredClone.Name = fNumber;		
		}
		return obscuredClone;
	}
	
    /*
    *@description Updates all BDP Contacts, for which original record has been changed and drops Lookup value to Salesforce contact
    */
	protected override List<sObject> getStatusConfirmationList() {
		List<sObject> statusConfirmationList = super.getStatusConfirmationList();
		
		sfContactsToObfuscate = getContactsToObfuscate();
		
		for (sObject obfuscatedObject : statusConfirmationList) {
			if (!sfContactsToObfuscate.contains(newSfContactMapping.get(obfuscatedObject.Id))) {
				obfuscatedObject.put(SF_CONTACT_LOOKUP, null);
			}
		}
		
		return statusConfirmationList;
	}     
	
    /*
    *@description Retrieves list of Salesforce contacts for which all BDP Contacts are obscured
    */
	private Set<Id> getContactsToObfuscate() {
		Set<Id> toObfuscate = new Set<Id>();
		
		if (sfContactsToCheck.size() > 0) {
			List<sObject> remainnigBdpContacts = [SELECT Salesforce_Contact__c, COUNT(Id) cnt
						FROM BDP_Contact__c
						WHERE Salesforce_Contact__c IN :sfContactsToCheck
						AND GDPR_Obscuration_Requested__c = false
						GROUP BY Salesforce_Contact__c];
					
			Set<Id> sfContactsToKeep = new Set<Id>();	
			for (sObject groupObject : remainnigBdpContacts) {
				Id contactId = (Id)groupObject.get(SF_CONTACT_LOOKUP);
				Integer totalCount = (Integer)groupObject.get('cnt');
				if (totalCount != null && totalCount > 0) {
					sfContactsToKeep.add(contactId);
				}
			}
			
			for (Id sfContactId : sfContactsToCheck) {
				if (!sfContactsToKeep.contains(sfContactId)) {
					toObfuscate.add(sfContactId);
				}
			}
		}
		return toObfuscate;
	}
	
    /*
    *@description Extended finish method. It updates required contacts, marking them as requested for obscuration,
    * if all related BDP Contacs for them are obscured
    */
	global override void finish(Database.BatchableContext BC) {	
		super.finish(BC);
		
		if (sfContactsToObfuscate != null && sfContactsToObfuscate.size() > 0) {
			List<Contact> contactsToObfuscate = new List<Contact>();
			for (Id sfContactId : sfContactsToObfuscate) {
				contactsToObfuscate.add(new Contact(
					Id = sfContactId, 
					GDPR_Obscuration_Requested__c = true,
					GDPR_Salesforce_Mastered__c = true
				));
			}	
			Database.update(contactsToObfuscate, true);
		}
	}	  
	
	
	/*
	*@description Static Service Layer method, which should be included to trigger to start raise obscuration process
	* for requested items.
	*/
	public static void processObfuscationOnTrigger(List<BDP_Contact__c> bdpContactList, Map<Id, BDP_Contact__c> oldValues) {
		if (!bdpObscurationIsInProgress) {
			BDPContactObfuscationProcessor processor = new BDPContactObfuscationProcessor();
			processor.checkObfuscationOnTrigger(bdpContactList, oldValues);
		}
	}
}