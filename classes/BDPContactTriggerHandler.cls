/* -----------------------------------------------------------------------------------------------
     Name:            BDPContactTriggerHandler.cls 
     Description:     Process Contact Data dependent on BDP Contact
	Test Class: 	  BDPContactTriggerHandlerTest.cls
	Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   4-June-2018           0.1         Vijay Sonawane         Initial
  ------------------------------------------------------------------------------------------------  */
public with sharing class BDPContactTriggerHandler {
		private final static String SF_CONTACT_ID_FIELD = 'Salesforce_Contact__c';
		private final static String EMAIL_OPT_OUT_FIELD = 'Email_opt_out__c';
		@TestVisible private static Boolean processSynchronously = false;
	
        /**
        * @desction Process method on after insert trigger event
        **/
        public static void onAfterInsert(List<BDP_Contact__c> bdpContactList) {
            try{
                setContactDependentData(bdpContactList, new Map<Id, BDP_Contact__c>());
            }catch(Exception ex){
                System.debug(ex);
                throw ex;
            }
        }
        
        /**
        * @desction Process method on after update trigger event
        **/
        public static void onAfterUpdate(List<BDP_Contact__c> bdpContactList, Map<Id, BDP_Contact__c> oldValues) {
            try{
                setContactDependentData(bdpContactList, oldValues);
            }catch(Exception ex){
                System.debug(ex);
                throw ex;
            }
        }
        
        /**
        * @desction Return boolean value or false, if those value is null
        **/
        private static Boolean notNullBool(Boolean value) {
        	return (value == null) ? false : value;
        }
        
        /**
        * @desction Return boolean value or false, if those value is null
        **/
        private static Map<Id, Boolean>getSfContactOptOutMap(List<BDP_Contact__c> bdpContactList, Map<Id, BDP_Contact__c> oldValues) {
            Map<Id, Boolean> salesforceContactUpdateMap = new Map<Id, Boolean>();
            BDP_Contact__c oldValue = null;
      
            for (BDP_Contact__c bdpContact : bdpContactList) {
            	oldValue = oldValues.get(bdpContact.Id);
            	
            	if (oldValue != null && oldValue.Salesforce_Contact__c != bdpContact.Salesforce_Contact__c &&
            		oldValue.Salesforce_Contact__c != null) {
            		salesforceContactUpdateMap.put(
            			oldValue.Salesforce_Contact__c,
            			notNullBool(salesforceContactUpdateMap.get(oldValue.Salesforce_Contact__c)) || false
            		);
            	}
            	
            	if (bdpContact.Salesforce_Contact__c != null && (oldValue == null ||
            		oldValue.Salesforce_Contact__c != bdpContact.Salesforce_Contact__c ||
            		oldValue.Email_Opt_Out__c != bdpContact.Email_Opt_Out__c)) {
            		salesforceContactUpdateMap.put(
            			bdpContact.Salesforce_Contact__c,
            			notNullBool(salesforceContactUpdateMap.get(bdpContact.Salesforce_Contact__c)) || bdpContact.Email_opt_out__c
            		);
            	}
            }
        	return salesforceContactUpdateMap;
        }
        
        /**
        * @desction Populate values of Historical Opt Out and GDPR Salesforce Mastered fields in Salesforce Contact
        * based on BDP Contact updated Data
        **/
        private static void setContactDependentData(List<BDP_Contact__c> bdpContactList, Map<Id, BDP_Contact__c> oldValues) {
            List<Contact> contactsToUpdate = new List<Contact>();
            Set<Id> contactsToRecalculate = new Set<Id>();
            Map<Id, Boolean> salesforceContactUpdateMap = getSfContactOptOutMap(bdpContactList, oldValues);
            
            Boolean isEmailOptedOut = false;
            for (Id sfContactId : salesforceContactUpdateMap.keySet()) {
            	isEmailOptedOut = salesforceContactUpdateMap.get(sfContactId);
            	if (isEmailOptedOut) {
            		contactsToUpdate.add(new Contact(
            			Id = sfContactId,
            			HasOptedOutOfEmail = true,
            			GDPR_Salesforce_Mastered__c = false
            		));
            	} else {
            		contactsToRecalculate.add(sfContactId);
            	}
            }
            
            if (contactsToUpdate.size() > 0) {
            	Database.update(contactsToUpdate);
            }

            
            if (contactsToRecalculate.size() > 0) {
	            if (!System.isBatch() && !System.isFuture() && !System.isScheduled() && !processSynchronously) {
	            	asyncRecalculateContactDepenencies(contactsToRecalculate);
	            } else {
	            	recalculateContactDepenencies(contactsToRecalculate);	
	            }
            }
        }        
        
        /**
        * @desction Recalculate HasOptedOutOfEmail and GDPR Salesforce Mastered based on information
        **/
        public static void recalculateContactDepenencies(Set<Id> contactIds) {
 			Map<Id, Contact> contactDataToUpdate = new Map<Id, Contact>();
 			Id salesforceContactId = null;
 			Boolean emailOptOut = false;
 			Contact currentContact = null;
 			
 			for (Id contactId : contactIds) {
 				contactDataToUpdate.put(contactId, new Contact(
 				 		Id = contactId,
 				 		HasOptedOutOfEmail = false,
 				 		GDPR_Salesforce_Mastered__c = true
 				)); 
 			}
 			
 			for (sObject aggregateContactData : [SELECT Salesforce_Contact__c, Email_opt_out__c
        		FROM BDP_Contact__c
        		WHERE Salesforce_Contact__c IN :contactIds
        		GROUP BY Salesforce_Contact__c, Email_opt_out__c
        	]) {
 				 salesforceContactId = (Id)aggregateContactData.get(SF_CONTACT_ID_FIELD);
 				 emailOptOut = (Boolean)aggregateContactData.get(EMAIL_OPT_OUT_FIELD);
 				 currentContact = contactDataToUpdate.get(salesforceContactId);
 				 currentContact.GDPR_Salesforce_Mastered__c = false;
 				 currentContact.HasOptedOutOfEmail = currentContact.HasOptedOutOfEmail || emailOptOut;
 			}
 			
 			if (contactDataToUpdate.size() > 0) {
 				Database.update(contactDataToUpdate.values());
 			}
        }       
        
        /**
        * @desction Do contact recaclulation asynchronously
        **/
        @future 
        private static void asyncRecalculateContactDepenencies(Set<Id> contactIds) {
 			recalculateContactDepenencies(contactIds);
        }                
}