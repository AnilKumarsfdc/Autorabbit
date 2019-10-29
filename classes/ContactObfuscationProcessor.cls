/* --------------------------------------------------------------------------------------------------
Name:            ObfuscationProcessor.cls 
Description:     Class which executes Obscuration functionality for Salesforce Contact object
Test class:      ObfuscationProcessorTest.cls 
------------------------------------------------------------------------------------------------ */
global with sharing class ContactObfuscationProcessor extends ObfuscationProcessor {
	@TestVisible
	private static Boolean contactObscurationIsInProgress = false;
	
	global Id confidentialProjectToReparentId;
	
	/*
	*@description Public constructor class
	*/
    public ContactObfuscationProcessor() {
        super(Contact.sObjectType);
        objectsExcludedFromReparenting.add('Preferences__c');
        confidentialProjectToReparentId = null;
    }
    
    /*
    * @description Interface start method, extended method also includes query of dummy account to  reparent from Custom Settings
    */
    global override Database.QueryLocator start(Database.BatchableContext BC) { 
    	confidentialProjectToReparentId = getConfidentialProjectToRepart();
    	return super.start(BC);  	
	}
	
    /*
    * @description Returns Id of Dummy Account from name specified in Custom Settnigs, or null if it's not set, not found
    */
	private Id getConfidentialProjectToRepart() {
		Id resultAccountId = null;
		Config_Settings__c configSettings = Config_Settings__c.getInstance();
		if (configSettings != null && configSettings.Obfuscation_Dummy_Account_Name__c != null) {
			Account[] dummyAccountData = [SELECT Id FROM Account 
										  WHERE Name = :configSettings.Obfuscation_Dummy_Account_Name__c
										  LIMIT 1];
										  
			if (dummyAccountData.size() > 0) {
				resultAccountId = dummyAccountData.get(0).Id;
			}
		}
		
		return resultAccountId;
	}

    
    /*
    *@description Extended getObscuredClone method, which updates AccountId to Dummy Confidential Project if it's set
    */
    protected override sObject getObscuredClone(sObject origin) {
		Contact obscuredClone = (Contact)super.getObscuredClone(origin);
		if (confidentialProjectToReparentId != null) {
			obscuredClone.AccountId = confidentialProjectToReparentId;
		}
		return obscuredClone;
	}	
    
	/*
	*@description Extended execute method. It should update all unobscured related BDP Contacts and unset value of 
	*Salesforce Contact.
	*/
    global virtual override void execute(Database.BatchableContext BC, List<sObject> scopeList) {
    	contactObscurationIsInProgress = true;
    	super.execute(BC, scopeList);
    	
    	List<BDP_Contact__c> bdpContactsToUpdate = [SELECT Id, Salesforce_Contact__c 
    		FROM BDP_Contact__c
    		WHERE Salesforce_Contact__c IN :transferedRecordsIdMap.values()
    		AND GDPR_Obscuration_Requested__c = false];
    		
    	for (BDP_Contact__c bdpContact : bdpContactsToUpdate) {
    		bdpContact.Salesforce_Contact__c = null;
    	}	
    	Database.update(bdpContactsToUpdate, false);
    	contactObscurationIsInProgress = false;
    }   
	
	/*
	*@description Static Service Layer method, which should be included to trigger to start raise obscuration process
	* for requested items.
	*/
	public static void processObfuscationOnTrigger(List<Contact> bdpContactList, Map<Id, Contact> oldValues) {
		if (!contactObscurationIsInProgress) {
			ContactObfuscationProcessor processor = new ContactObfuscationProcessor();
			processor.checkObfuscationOnTrigger(bdpContactList, oldValues);
		}
	}
}