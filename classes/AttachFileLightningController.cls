/* --------------------------------------------------------------------------------------------------
     Name:            AttachFileLightningController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
  of Uploading Attachments to Company Folders
  Test class:      AttachFileLightningControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class AttachFileLightningController {

    private static final String UTF_ENCODE = 'UTF-8';
    private static final String SHARE_TYPE = 'I';
    private static final String CONTENT_LOCATION = 'S';
    private static final string COMMA = ',';


    /**
     * @description: This method gets the Folder Type and Document Type from Metadata
     * 
     **/
    @AuraEnabled
    public static Map<String, List<String>> getDocumentTypes() {

        Map<String, List<String>> folderTagMap = new Map<String, List<String>> ();

        for (Company_Folder_Metadata__mdt folderMdt :[SELECT Folder_Type__c, Tag__c, Document_Type__c
                                                      FROM Company_Folder_Metadata__mdt LIMIT 1000]) {
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
     * @description : save attachments  .
     * 
     **/
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType,
                                  String description, Boolean isLastChunk, String attachId) {
        try {
            if (attachId == null) {
                attachId = saveTheFile(parentId, fileName, base64Data, contentType, description);
            } else {
                appendToFile(attachId, base64Data);
            }

            if (isLastChunk == true) {
                convertAttachmentToContent(attachId);
            }

            return Id.valueOf(attachId);
        }
        catch(Exception e) {
            throw e;
        }
    }

    /**
     * @description Update Attachements  .
     * 
     **/
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, UTF_ENCODE);

        Attachment a = [
                        SELECT Id, Body
                        FROM Attachment
                        WHERE Id = :fileId LIMIT 1000
                       ];

        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);

        try {
            Database.update(a);
        }
        catch(Exception e) {
            throw e;
        }

    }

    /**
     * @description Insert Attachements   .
     * 
     **/
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String description) {

        base64Data = EncodingUtil.urlDecode(base64Data, UTF_ENCODE);

        Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        attach.ContentType = contentType;
        attach.Description = description;

        try {
            Database.insert(attach);
        }

        catch(Exception e) {
            throw e;
        }

        return attach.Id;
    }


    /**
     * @description : Get and return list of Company Folders based on Company  .
     * 
     **/
    @AuraEnabled
    public static List<Company_Folder__c> getfolderName(Id companyId) {
        try {
            List<Company_Folder__c> str = new List<Company_Folder__c> ();
            for (Company_Folder__c fld :[SELECT ID, Name FROM Company_Folder__c WHERE Company__c = :companyId
                 LIMIT 10000]) {
                str.add(fld);
            }
            return str;
        }
        catch(Exception e) {
            throw e;
        }
    }

    /**
     * @description : Convert uploaded attachment to Content Document
     * 
     **/
    @future
    public static void convertAttachmentToContent(String attachmentId) {
        Attachment attach = [SELECT Id, ParentId, Name, Description, ContentType, Body
                             FROM Attachment
                             WHERE Id = :attachmentId
                             LIMIT 10000];
        if (attach != Null) {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = CONTENT_LOCATION;
            cv.VersionData = attach.Body;
            cv.Title = attach.Name;
            cv.PathOnClient = attach.Name;
            cv.Description = attach.Description;
            cv.TagCsv = attach.Description;
            Database.insert(cv);
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 10000];

            ContentDocumentLink cdl = new ContentDocumentLink();
            Id contentid = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
                            LIMIT 10000].ContentDocumentId;
            cdl.ContentDocumentId = contentid;
            cdl.LinkedEntityId = attach.ParentId;
            cdl.ShareType = SHARE_TYPE;

            try {
                Database.insert(cdl);
                Database.delete(attach);
            }

            catch(Exception e) {
                throw e;
            }
        }
    }
}