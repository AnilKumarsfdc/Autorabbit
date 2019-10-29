/* --------------------------------------------------------------------------------------------------
  Name:            TagAttachmentsLightningController.cls 
  Description:     Aura controller of Lightning component which is used to Tag Attachments.
  Test class:      TagAttachmentsLightningControllerTest.cls 
  ------------------------------------------------------------------------------------------------ */
public with sharing class TagAttachmentsLightningController {
	private static final String SHARE_TYPE = 'I';
	private static final String EMPTY_STRING = '';
    private static final String CAT_FORM_MATCH = 'CAT Form';
	private static final String ERROR_MESSAGE = 'You can tag CAT Form only to an excel attachment';
	private static final Map<string, string> MIME_TYPE_MAP = new Map<string, string> {
		'EXCEL_X' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'EXCEL_M' => 'application/vnd.ms-excel.sheet.macroEnabled.12'
            
	};

	 /**
     * @description : Get and return list of Company Folders based on Case.
     * 
     **/
    @AuraEnabled
    public static List<Company_Folder__c> getfolderName(Id caseId) {
        try {
			
			Case caseObj = [SELECT Id, AccountId
							FROM Case
							WHERE Id=: caseId
                            LIMIT 1];

            List<Company_Folder__c> comFolList = new List<Company_Folder__c> ();
            for (Company_Folder__c comFol :[SELECT Id, Name 
											FROM Company_Folder__c 
											WHERE Company__c = :caseObj.AccountId
											AND Name IN ('KYC AML AOS',
                                                         'KYC, AML & FinCrime Documentation',
                                                         'KYC, AML and FinCrime Documentation',
                                                         'Account Opening')
											LIMIT 1000]) {
                comFolList.add(comFol);
            }
            return comFolList;
        }
        catch(Exception e) {
            throw e;
        }
    }

	/**
     * @description: This method gets the Folder Type and Document Type from Metadata
     * 
     **/
    @AuraEnabled
    public static Map<String, List<String>> getDocumentTypes() {

        Map<String, List<String>> folderTagMap = new Map<String, List<String>> ();

        for (Company_Folder_Metadata__mdt folderMdt :[SELECT Folder_Type__c, Tag__c, Document_Type__c
                                                      FROM Company_Folder_Metadata__mdt													  
													  LIMIT 1000]) {
            if (folderTagMap.get(folderMdt.Folder_Type__c) != null) {
                List<String> tagList = folderTagMap.get(folderMdt.Folder_Type__c);
                tagList.add(folderMdt.Document_Type__c);
                folderTagMap.put(folderMdt.Folder_Type__c, tagList);
            } else {
                folderTagMap.put(folderMdt.Folder_Type__c, new List<String> { folderMdt.Document_Type__c });
            }
        }

        return folderTagMap;
    }

	/**
     * @description: This method gets the Attachments
     * 
     **/
    @AuraEnabled
    public static List<AttachmentWrapper> getAttachments(Id caseId) {
		
		List<AttachmentWrapper> attWrapperList = new List<AttachmentWrapper>();
		Set<Id> conDocIds = new Set<Id>();
		Map<Id, String> conDocMap = new Map<Id, String>();
 
        if (caseId != null) {
            for(ContentDocumentLink conDoc : [SELECT Id, ContentDocumentId
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId =:caseId
                                              LIMIT :GlobalConstants.MAX_QUERY_LIMIT]){
                conDocIds.add(conDoc.ContentDocumentId);								  
            }
        }
			
        if (conDocIds.size() > 0) {
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId, 
                                           ContentDocument.LatestPublishedVersion.Title, 
                                           ContentDocument.LatestPublishedVersion.Description
                                           FROM ContentDocumentLink
                                           WHERE ContentDocumentId IN : conDocIds
                                           LIMIT :GlobalConstants.MAX_QUERY_LIMIT]){
                if(cdl.ContentDocument.LatestPublishedVersion.Description == null && 
                   cdl.LinkedEntityId.getSObjectType() == Case.sObjecTtype) {
                    attWrapperList.add( new AttachmentWrapper(
                        cdl.ContentDocumentId,
                        cdl.ContentDocument.LatestPublishedVersion.Title,
                        EMPTY_STRING,
                        EMPTY_STRING, 
                        false
                    ));
                }							   
            }
        }
        return attWrapperList; 
    }
	
	/**
	* @description: This method updates Content Version and shares the attachment with Company Folder
	* 
	**/
    @AuraEnabled
    public static void saveAttachments(Id caseId, string updateAttachmentWrapperString) {
		AuraHandledException e;
        List<AttachmentWrapper> attachmentWrapperList = null;	
		List<ContentVersion> recordsToUpdate = new List<ContentVersion> ();
		List<ContentDocumentLink> conDocRecordsToInsert = new List<ContentDocumentLink>();	
		Map<Id, String> attWrapMap = new Map<Id, String>();
		Map<Id, String> comFolderMap = new Map<Id, String>();
		String attachmentDetails = EMPTY_STRING;
		List<String> attDetailsList = new List<String>();


		Case caseObj = [SELECT Id, AccountId, Attachment_Details__c
						FROM Case
						WHERE Id=: caseId
                       	LIMIT 1];
		
		if (caseObj.Attachment_Details__c != null) {
			attDetailsList = caseObj.Attachment_Details__c.split('\n');
		}

        
        if (updateAttachmentWrapperString != null) {
            attachmentWrapperList = (List<AttachmentWrapper>) JSON.deserialize(updateAttachmentWrapperString,
                                                                            List<AttachmentWrapper>.class);
        }

		for(AttachmentWrapper attWrap : attachmentWrapperList){
			if(attWrap.contentDocumentId != null && attWrap.tag != null && attWrap.companyFolder != null){
				attWrapMap.put(attWrap.contentDocumentId, attWrap.tag);
				comFolderMap.put(attWrap.contentDocumentId, attWrap.companyFolder);
			}
		}

		if(! attWrapMap.isEmpty()){
			for (ContentVersion conVer : [SELECT Id, ContentDocumentId, Title, FileExtension, 
                                          		 FileType, Description, PathOnClient
										  FROM ContentVersion 
									      WHERE ContentDocumentId IN : attWrapMap.keySet()
                                          LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
					
					conVer.Description = attWrapMap.get(conVer.ContentDocumentId);

					if(CAT_FORM_MATCH.equalsIgnoreCase(conVer.Description) && 
                       (!MIME_TYPE_MAP.containsKey(conVer.FileType))){
						e = new AuraHandledException(ERROR_MESSAGE);
						e.setMessage(ERROR_MESSAGE);
						throw e;
					} else {
						recordsToUpdate.add(conVer);
					}

					attDetailsList.add(''+ conVer.PathOnClient + '/' + conVer.Description +'');
					

					ContentDocumentLink cdl = new ContentDocumentLink();
					cdl.ContentDocumentId = conVer.ContentDocumentId;
					cdl.LinkedEntityId = comFolderMap.get(conVer.ContentDocumentId);
					cdl.ShareType = SHARE_TYPE;
					conDocRecordsToInsert.add(cdl);
			}
		}

		for(string attDetail : attDetailsList){
			if ((attachmentDetails != '') && (attDetail != null)) {attachmentDetails += '\n';}
			if ((attDetail != null)) {attachmentDetails += attDetail;}
		}
				
		caseObj.Attachment_Details__c = attachmentDetails;

		if (recordsToUpdate != null && recordsToUpdate.size() > 0 &&
			conDocRecordsToInsert != null && conDocRecordsToInsert.size() > 0 ) {
			try {
				Database.update(recordsToUpdate);
				Database.insert(conDocRecordsToInsert);
				Database.update(caseObj);
			} catch (AuraHandledException ex){
                throw ex;
            }
		}
    } 

	 /**
	* @description: Wrapper Class and its constructor
	* 
	**/
    public class AttachmentWrapper{
		@AuraEnabled public string contentDocumentId {get; set;}
		@AuraEnabled public string attachmentTitle {get; set;}
		@AuraEnabled public string companyFolder {get; set;}
		@AuraEnabled public string tag {get; set;}
        @AuraEnabled public Boolean tagged {get; set;}
        
        public AttachmentWrapper(string selectedConDocId, string selectedTitle, 
                                 string selectedFolder, string selectedTag, boolean isTagged){
			contentDocumentId = selectedConDocId;
            attachmentTitle = selectedTitle;
			companyFolder = selectedFolder;
			tag = selectedTag;
            tagged = isTagged;
        }  
    }
}