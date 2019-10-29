/* --------------------------------------------------------------------------------------------------
  Name:            sendCaseEmailNotification.cls 
  Description:     Aura controller of Lightning component which is used to Send AOS Emails from Case Object.
  Test class:      sendCaseEmailNotificationTest.cls 
  ------------------------------------------------------------------------------------------------ */
public with sharing class sendCaseEmailNotification {
    
	private static final String ERROR_MESSAGE = 'Please tag at least one attachement';
	private static final String ONBOARDING_RECORD_TYPE = 'Onboarding';
	private static final String KYC_RECORD_TYPE = 'KYC Update';
	private static final String DISPLAY_NAME = 'Rapport CRM';
	private static final String TEMPLATE_NAME = 'AOS Email Template';
	private static final String CAT_DESCRIPTION = 'CAT Form';
  
	/**
	* @description: This method gets the attachments which are tagged as CAT FORM.
	* 
	**/
    @AuraEnabled
    public static List<ContentDocumentLink> getAttachments(Id caseId) {
		

		List<ContentDocumentLink> conDocList = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersion.Title ,
													   ContentDocument.LatestPublishedVersion.Description
												FROM ContentDocumentLink 
												WHERE LinkedEntityId =:caseId
												AND ContentDocument.LatestPublishedVersion.Description = :CAT_DESCRIPTION
                                                LIMIT 10000];
        return conDocList; 
    } 
    
	/**
	* @description: This method sends the email with attachments to AOS.
	* 
	**/
    @AuraEnabled
    public static void sendCaseEmail(Id caseId){

		Id onboardingRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ONBOARDING_RECORD_TYPE).getRecordTypeId();
		Id kycRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(KYC_RECORD_TYPE).getRecordTypeId();

		AuraHandledException e;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> aosToAddresses = new List<String> (); 
		List<String> kycToAddresses = new List<String> (); 
		List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        List<Configuration__c> configList = Configuration__c.getAll().values();

		OrgWideEmailAddress oWA = [SELECT Id, Address, DisplayName 
								   FROM OrgWideEmailAddress
								   WHERE DisplayName = :DISPLAY_NAME
								   LIMIT 1];

		EmailTemplate emailTemp = [SELECT Id, Subject, Body, HtmlValue 
								   FROM EmailTemplate 
								   WHERE Name = :TEMPLATE_NAME 
								   LIMIT 1];
        
		for(Configuration__c config : configList)
        {
           aosToAddresses.add(config.AOS_Email__c);
		   kycToAddresses.add(config.KYC_Email__c);
        }

		Case caseObj = [SELECT Id, AccountId, RecordTypeId, Attachment_Details__c, OwnerId
						FROM Case
						WHERE Id=: caseId];

        Messaging.SingleEmailMessage emailMsg = Messaging.renderStoredEmailTemplate(emailTemp.Id, caseObj.OwnerId, caseId);
        
			if(caseObj.RecordTypeId == onboardingRecordType && (! aosToAddresses.isEmpty())) {
				mail.setToAddresses(aosToAddresses);
			} else if(caseObj.RecordTypeId == kycRecordType && (! kycToAddresses.isEmpty())) {
				mail.setToAddresses(kycToAddresses);
			}
        	
        	mail.setOrgWideEmailAddressId(oWA.Id);
        	mail.setUseSignature(false);
        	mail.setTemplateId(emailTemp.Id);
        	mail.setTargetObjectId(caseObj.OwnerId);
        	mail.setSubject(emailMsg.getSubject());
        	mail.setHTMLBody(emailMsg.getPlainTextbody());
        	mail.setsaveAsActivity(False);
        
		//Set email file attachments        
        Set<id> contentId = new Set<id>();
        Set<id> conDocIdList = new Set<id>();
        Set<Id> tagedAtt = new Set<Id>();
       
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId
									   FROM ContentDocumentLink
									   WHERE LinkedEntityId = :caseId
									   LIMIT 10000]){
			contentId.add(cdl.ContentDocumentId);
        }
        
        for(ContentDocument cd :[SELECT FileType,Id,Title,Description 
								 FROM ContentDocument
								 WHERE Id =:contentId
								 LIMIT 10000]) {
            if(cd.Description != NULL){
                tagedAtt.add(cd.Id);
            }
            conDocIdList.add(cd.Id);
        }

        if(tagedAtt.size()>0){
			for(ContentVersion cv1 : [SELECT PathOnClient,FileExtension,FileType,Id,Title,VersionData 
									  FROM ContentVersion
									  WHERE ContentDocumentId =: conDocIdList
									  LIMIT 10000]){

				Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        		efa.setFileName(cv1.PathOnClient);
        		efa.setBody(cv1.VersionData);
        		fileAttachments.add(efa);
       		}  
        } else {
			e = new AuraHandledException(ERROR_MESSAGE);
			e.setMessage(ERROR_MESSAGE);
			throw e;
        }
  
		// Add to attachment file list    
        if(fileAttachments.size()>0){
            mail.setFileAttachments(fileAttachments);
        }
        
		//Send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}      
 }