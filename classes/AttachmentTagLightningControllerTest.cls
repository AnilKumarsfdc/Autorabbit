/* --------------------------------------------------------------------------------------------------
     Name:            AttachmentTagLightningControllerTest.cls 
     Description:     Test class for AttachmentTagLightningController.cls
    ------------------------------------------------------------------------------------------------ */

@isTest(SeeAllData = false)
public with sharing class AttachmentTagLightningControllerTest {
    
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final String PROSPECT_COMPANY_RECORD_TYPE = 'Prospect';
    private static final String CUSTOMER_COMPANY_RECORD_TYPE = 'Customer';
    private static final String SR_CASE_RECORD_TYPE = 'Servicing Request';
    private static final String DOC_TYPE = 'KYC';
    private static final String COMPLAINT_RECORD_TYPE = 'Complaint';
    private static final String SHARE_TYPE = 'I';
    private static final String CONTENT_LOCATION = 'S';
    
    @isTest private static void runPositiveTests() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        
        String name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        String description = 'Test Description';
        
        Schema.DescribeSObjectResult cfrCaseSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrCaseSchema.getRecordTypeInfosByName();
        List<Case> caseList = new List<Case> ();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        Account acct = new Account(Name = 'Test');
        Database.insert(acct);
        
        Case onboardingCase = new Case(AccountId = acct.Id, Status='Pre AOS', J_Number__c = 'J1236789',
                                       RecordTypeId = caseRecordTypeInfo.get(COMPLAINT_RECORD_TYPE).getRecordTypeId());
        caseList.add(onboardingCase);
        Database.insert(caseList);
        
        List<Company_Folder__c> comFolderList = [SELECT Id, Name from Company_Folder__c 
                                                 WHERE Company__c = :acct.Id 
                                                 AND NAME IN ('KYC, AML and FinCrime Documentation','Account Opening')
                                                 LIMIT 10000];
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = CONTENT_LOCATION;
        cv.VersionData = bodyBlob;
        cv.Title = name;
        cv.PathOnClient = name;
        Database.insert(cv);
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 10000];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1000].ContentDocumentId;
        cdl.LinkedEntityId = onboardingCase.Id;
        cdl.ShareType = SHARE_TYPE;
        cdlList.add(cdl);
        Database.insert(cdlList); 
        
        test.startTest();
        
        Company_Folder__c[] comFol = AttachmentTagLightningController.getfolderName(onboardingCase.Id);        
        Map<String, List<String>> tags = AttachmentTagLightningController.getDocumentTypes();        
        List<ContentDocumentLink> conDocsList = AttachmentTagLightningController.getAttachments(onboardingCase.Id);
        
        
        cv.TagCsv = description;
        cv.Company_Folder__c = comFolderList[0].Id;
        cvList.add(cv);
        String contentVersionToUpdate = JSON.serialize(cvList);
        AttachmentTagLightningController.saveAttachments(contentVersionToUpdate);
        
        ContentVersion conVer = [SELECT Id, ContentDocumentId, TagCsv, Company_Folder__c, Description
                                 FROM ContentVersion
                                 WHERE Id=: cv.Id];
        test.stopTest();
        
        System.assertEquals(comFolderList.size(), comFol.size());
        System.assertEquals(cdlList.size(), conDocsList.size());
        System.assertEquals(description, conVer.Description);
        
    }
}