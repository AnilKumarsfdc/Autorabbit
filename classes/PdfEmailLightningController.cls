/* --------------------------------------------------------------------------------------------------
  Name:            PdfEmailLightningController.cls 
  Description:     Aura controller of Lightning component which is used to Send Meeting Record
  as a PDF along with the attachment(s)
  Test class:      PdfEmailLightningControllerTest.cls 
  ------------------------------------------------------------------------------------------------ */
public with sharing class PdfEmailLightningController {
	private static final Map<string, string> MIME_TYPE_MAP = new Map<string, string> {
		'POWER_POINT_X' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
		'EXCEL_X' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
		'WORD_X' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
		'POWER_POINT' => 'application/vnd.ms-powerpoint',
		'EXCEL' => 'application/vnd.ms-excel',
		'WORD' => 'application/vnd.ms-word',
		'PDF' => 'application/pdf',
		'TEXT' => 'text/plain',
		'JPG' => 'image/jpeg',
		'GIF' => 'image/gif',
		'PNG' => 'image/png',
		'MP4' => 'video/mp4'
	};

	private static final string COMMA = ',';
	private static final string ERROR_MESSAGE = 'Please Enter Valid Email Id(s)';
	private static final string EMAIL_PATTERN = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
	private static final string PDF_MEETING_ID = 'Id';
	private static final string UNIT_TEST = 'UNIT.TEST';
	private static final string APPLICATION_TYPE = 'application/pdf';
	private static final string FILE_NAME = 'Meeting.pdf';
	private static final string EMAIL_SUBJECT = 'Meeting Report';
	private static final string EMAIL_BODY = 'Below please find Meeting Report you requested. Kindly check the attachment.';
	private static final String DOT = '.';
    
	/**
	 * @description Get user info by id
	 * @return String
	 **/
    @AuraEnabled
	public static User getUserById(Id userId) {
		User selectedUser;
        try {
			selectedUser = [SELECT Id, Name, Email FROM User WHERE Id = :userId LIMIT 1];
		}
		catch(Exception e) {
			selectedUser = null;
		}
        return selectedUser;
	}

	/**
	 * @description Get the Email Id(s) along with the Meeting Record ID and send it to send pdf method
	 * @return Map 
	 **/
	@AuraEnabled
	public static Map<Id, List<String>> sendEmailFromPage(ID meetingId, List<String> emailList) {
		try {
			/*List<String> emailList = new List<String> ();
			
			if (email != null) {
				emailList = email.Split(COMMA);
			} */
			AuraHandledException e;
			List<String> validEmailResults = new List<String> ();
			List<String> invalidEmailResults = new List<String> ();
			if (emailList.size() > 0) {
				for (String emailReg : emailList) {
                    
                    validEmailResults.add(emailReg.trim());
                    
                    /*
					if (Pattern.matches(EMAIL_PATTERN, emailReg.trim()))
					{
						validEmailResults.add(emailReg.trim());
					}
					else
					{
						invalidEmailResults.add(emailReg);
						e = new AuraHandledException(ERROR_MESSAGE);
						e.setMessage(ERROR_MESSAGE);
						throw e;
					} 
					*/
				}
			}

			if (validEmailResults.size() == 0 || validEmailResults == NULL) {
				//invalidEmailResults.add(email);
				e = new AuraHandledException(ERROR_MESSAGE);
				e.setMessage(ERROR_MESSAGE);
				throw e;
			}

			map<Id, List<string>> mapMeetingIdEmailListFromPage = new map<Id, List<string>> ();
			mapMeetingIdEmailListFromPage.put(meetingId, validEmailResults);
			sendPdf(mapMeetingIdEmailListFromPage);
			return mapMeetingIdEmailListFromPage;

		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description Send Meeting Record as a PDF along with the attachment(s)
	 **/
	public static void sendPdf(map<Id, List<string>> mapMeetingIdEmailList) {
		Map<Id, Meeting__c> meetingMap;
		OrgWideEmailAddress[] oWaList = [SELECT Id, Address, DisplayName from OrgWideEmailAddress LIMIT 1];
		Messaging.SingleEmailMessage[] messageList = new list<Messaging.SingleEmailMessage> ();

		meetingMap = new Map<Id, Meeting__c> (
		                                      [SELECT Id, Name, Account__r.Name, Meeting_Type__c, Relationship_Type__c, Meeting_Address__c,
		                                      Start_DateTime__c, End_DateTime__c, Other_Attendees__c, Decline_Appeal__c, Fraud_Protection_Discussed__c,
		                                      Meeting_Agenda__c, Requirements__c, Structure__c, Strategy__c, Financials__c, Next_Steps_Actions__c,
		                                      Products_And_Services__c, Customers_And_Suppliers__c, International_Operations__c,
		                                      Needs_Changed__c, Needs_Changed_Detail__c, Customers_Changed__c, Documents_Detailed__c,
		                                      Customers_Changed_Detail__c, Nature_Changed__c, Nature_Change_Detail__c,CreatedDate,
		                                      Business_Operating_Expectations__c, Business_Operating_Detail__c, Observations__c,
		                                      Validated_Nature_Of_Business__c, Reason_Nature_Not_Validated__c, Outcome__c,
		                                      Credit_Decline_Notification__c, Credit_Decline_Detail__c, Documents_Attached__c,
		                                      PreCredit_Decline_Notification__c, PreCredit_Decline_Detail__c, Cancel_Reason__c,
		(SELECT Id, User__r.Name FROM User_Attendees__r),
		(SELECT Id, Contact__r.Name FROM Contact_Attendees__r)
		                                      FROM Meeting__c
		                                      WHERE Id IN : mapMeetingIdEmailList.keySet() LIMIT 10000]
		);

		Set<Id> meetingIdSet = mapMeetingIdEmailList.keySet();
		Map<Id, List<Messaging.EmailFileAttachment>> mapIdAndEmailAttachments = new Map<Id, List<Messaging.EmailFileAttachment>> ();
		Messaging.EmailFileAttachment efa;
		Messaging.SingleEmailMessage mail;
		for (ContentDocumentLink conDocLink :[SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersion.FileType,
		     ContentDocument.LatestPublishedVersion.FileExtension, ContentDocument.LatestPublishedVersion.VersionData,
		     ContentDocument.LatestPublishedVersion.PathOnClient, ContentDocument.LatestPublishedVersion.Title
		     FROM ContentDocumentLink WHERE LinkedEntityId IN :meetingIdSet LIMIT 10000]) {

			efa = new Messaging.EmailFileAttachment();
			efa.setFileName(conDocLink.ContentDocument.LatestPublishedVersion.Title + DOT + conDocLink.ContentDocument.LatestPublishedVersion.FileExtension);
			efa.setBody(conDocLink.ContentDocument.LatestPublishedVersion.VersionData);
			if (MIME_TYPE_MAP.containsKey(conDocLink.ContentDocument.LatestPublishedVersion.FileType)) {
				efa.setContentType(MIME_TYPE_MAP.get(conDocLink.ContentDocument.LatestPublishedVersion.FileType));
			}
			efa.setInline(false);

			if (mapIdAndEmailAttachments != null && !mapIdAndEmailAttachments.containskey(conDocLink.LinkedEntityId)) {
				mapIdAndEmailAttachments.put(conDocLink.LinkedEntityId, new List<Messaging.EmailFileAttachment> { efa });
			} else {
				mapIdAndEmailAttachments.get(conDocLink.LinkedEntityId).add(efa);
			}
		}

		//Populate static Page Cache, what will give ability to reuse data within PDF document rather then making a separate queries
		MeetingPdfTemplateExtension.meetingCache = meetingMap;

		for (String mId : mapMeetingIdEmailList.keySet()) {
			if (mapMeetingIdEmailList != null && mapMeetingIdEmailList.get(mId).size() > 0) {

				//PageReference pdf = Page.TemplateTest;
				PageReference pdf = Page.MeetingRecordTemplate1;
				pdf.getParameters().put(PDF_MEETING_ID, mId);
				Blob body;

				// the contents of the attachment from the pdf
				if (Test.IsRunningTest()) {
					body = Blob.valueOf(UNIT_TEST);
				} else {
					body = pdf.getContent();
				}


				// To send the PDF of Meeting record as an attachment
				efa = new Messaging.EmailFileAttachment();
				efa.setContentType(APPLICATION_TYPE);
				efa.setFileName(FILE_NAME);
				efa.setInline(false);
				efa.Body = body;
				if (mapIdAndEmailAttachments != null && !mapIdAndEmailAttachments.containskey(mId)) {
					mapIdAndEmailAttachments.put(mId, new List<Messaging.EmailFileAttachment> { efa });
				} else {
					mapIdAndEmailAttachments.get(mId).add(efa);
				}


				mail = new Messaging.SingleEmailMessage();
				mail.setUseSignature(false);
				if (oWaList.size() > 0) {
					mail.setOrgWideEmailAddressId(oWaList.get(0).Id);
				}
				mail.setToAddresses(mapMeetingIdEmailList.get(mId));
				mail.setSubject(EMAIL_SUBJECT);
				mail.setHtmlBody(EMAIL_BODY);
				mail.setFileAttachments(mapIdAndEmailAttachments.get(mId));

				// Adding Email Message to List
				messageList.add(mail);

			}
		}
		try {
			// Send the email
			Messaging.sendEmail(messageList);
		}
		catch(Exception e) {
			throw e;
		}
	}
}