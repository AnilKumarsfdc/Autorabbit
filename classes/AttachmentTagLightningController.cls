/* --------------------------------------------------------------------------------------------------
  Name:            AttachmentTagLightningController.cls 
  Description:     Aura controller of Lightning component which is used to Tag Attachments.
  Test class:      AttachmentTagLightningControllerTest.cls 
  ------------------------------------------------------------------------------------------------ */

public with sharing class AttachmentTagLightningController {

	private static final String SHARE_TYPE = 'I';

	 /**
     * @description : Get and return list of Company Folders based on Case.
     * 
     **/
    @AuraEnabled
    public static List<Company_Folder__c> getfolderName(Id caseId) {
        try {
			
			Case caseObj = [SELECT Id, AccountId
							FROM Case
							WHERE Id=: caseId];

            List<Company_Folder__c> comFolList = new List<Company_Folder__c> ();
            for (Company_Folder__c comFol :[SELECT Id, Name 
											FROM Company_Folder__c 
											WHERE Company__c = :caseObj.AccountId
											AND Name IN ('KYC, AML and FinCrime Documentation','Account Opening')
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
    public static List<ContentDocumentLink> getAttachments(Id caseId) {
		

		List<ContentDocumentLink> conDocList = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.Description
													FROM ContentDocumentLink 
													WHERE LinkedEntityId =:caseId
													AND ContentDocument.LatestPublishedVersion.Description = NULL
                                                	LIMIT 10000];
        return conDocList; 
    } 


	 /**
	* @description: This method updates Content Version and shares the attachment with Company Folder
	* 
	**/
    @AuraEnabled
    public static void saveAttachments(string updateContentVersionString) {
        List<ContentVersion> contentVersionToUpdate = null;	
		List<ContentVersion> recordsToUpdate = new List<ContentVersion> ();
		List<ContentDocumentLink> conDocRecordsToInsert = new List<ContentDocumentLink>();	
		Map<Id, String> conVersionMap = new Map<Id, String>();
		Map<Id, String> comFolderMap = new Map<Id, String>();
        
        if (updateContentVersionString != null) {
            contentVersionToUpdate = (List<ContentVersion>) JSON.deserialize(updateContentVersionString,
                                                                            List<ContentVersion>.class);
        }

		for(ContentVersion conVersion : contentVersionToUpdate){
			if(conVersion.ContentDocumentId != null && conVersion.TagCsv != null && conVersion.Company_Folder__c != null){
				conVersionMap.put(conVersion.ContentDocumentId, conVersion.TagCsv);
				comFolderMap.put(conVersion.ContentDocumentId, conVersion.Company_Folder__c);
			}
		}

		if(! conVersionMap.isEmpty()){
			for (ContentVersion conVer : [SELECT Id, ContentDocumentId, TagCsv, Company_Folder__c, Description
										  FROM ContentVersion 
									      WHERE ContentDocumentId IN : conVersionMap.keySet()]) {
					
					conVer.Description = conVersionMap.get(conVer.ContentDocumentId);
					recordsToUpdate.add(conVer);

					ContentDocumentLink cdl = new ContentDocumentLink();
					cdl.ContentDocumentId = conVer.ContentDocumentId;
					cdl.LinkedEntityId = comFolderMap.get(conVer.ContentDocumentId);
					cdl.ShareType = SHARE_TYPE;
					conDocRecordsToInsert.add(cdl);
			}
		}
		

		if (recordsToUpdate != null && recordsToUpdate.size() > 0 &&
			conDocRecordsToInsert != null && conDocRecordsToInsert.size() > 0) {
			try {
				Database.update(recordsToUpdate);
				Database.insert(conDocRecordsToInsert);
			} catch (AuraHandledException e){
                throw e;
            }
		}
    }
}