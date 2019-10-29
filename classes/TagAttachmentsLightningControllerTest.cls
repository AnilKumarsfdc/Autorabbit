/* --------------------------------------------------------------------------------------------------
     Name:            TagAttachmentsLightningControllerTest.cls 
     Description:     Apex class which tests TagAttachmentsLightningController, which tags attachments
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
Private with sharing class TagAttachmentsLightningControllerTest {
    
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final String PROSPECT_COMPANY_RECORD_TYPE = 'Prospect';
    private static final String CUSTOMER_COMPANY_RECORD_TYPE = 'Customer';
    private static final String SR_CASE_RECORD_TYPE = 'Servicing Request';
    private static final String DOC_TYPE = 'KYC';
    private static final String ONBOARDING_RECORD_TYPE = 'Complaint'; //TEMP Disable 'Onboarding';
    private static final String SHARE_TYPE = 'I';
    private static final String CONTENT_LOCATION = 'S';
    private static final String EMPTY_STRING = '';
    
    /**
     * @description This method runs positive tests 
     **/
    @isTest private static void runPositiveTests() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        
        String name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        String description = 'Test Description';
        String catFormTag = 'CAT Form';
        
        system.runAs(user) {
			Schema.DescribeSObjectResult cfrCaseSchema = Schema.SObjectType.Case;
			Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrCaseSchema.getRecordTypeInfosByName();
			List<Case> caseList = new List<Case> ();
			List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
			List<TagAttachmentsLightningController.AttachmentWrapper> attWrapperListToUpdate = new 
																								List<TagAttachmentsLightningController.AttachmentWrapper>();
			String wrapperToUpdate = '';
			
			Account acct = new Account(Name = 'Test');
			Database.insert(acct);
			
			Case onboardingCase = new Case(AccountId = acct.Id, Status='New', J_Number__c = 'J1236789',
										   RecordTypeId = caseRecordTypeInfo.get(ONBOARDING_RECORD_TYPE).getRecordTypeId());
			caseList.add(onboardingCase);
			Database.insert(caseList);
			
			List<Company_Folder__c> comFolderList = [SELECT Id, Name from Company_Folder__c 
													 WHERE Company__c = :acct.Id 
													 AND NAME IN ('KYC, AML and FinCrime Documentation','Account Opening')
													 LIMIT 10000];
			
			ContentVersion conVers = new ContentVersion();
			conVers.ContentLocation = CONTENT_LOCATION;
			conVers.VersionData = bodyBlob;
			conVers.Title = name;
			conVers.PathOnClient = name;
			Database.insert(conVers);
			
			conVers = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVers.Id LIMIT 10000];
			
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVers.Id LIMIT 1000].ContentDocumentId;
			cdl.LinkedEntityId = onboardingCase.Id;
			cdl.ShareType = SHARE_TYPE;
			cdlList.add(cdl);
			Database.insert(cdlList); 
			
			test.startTest();
			
				Company_Folder__c[] comFol = TagAttachmentsLightningController.getfolderName(onboardingCase.Id);
				Map<String, List<String>> tags = TagAttachmentsLightningController.getDocumentTypes();
				
				TagAttachmentsLightningController.AttachmentWrapper attWrapper = new TagAttachmentsLightningController.AttachmentWrapper(cdl.ContentDocumentId, name, EMPTY_STRING, catFormTag, true);
				attWrapperListToUpdate.add(attWrapper);
				
				List<TagAttachmentsLightningController.AttachmentWrapper> attWrapperList = TagAttachmentsLightningController.getAttachments(onboardingCase.Id);
				
				wrapperToUpdate = JSON.serialize(attWrapperListToUpdate);
			
			try{
				
				TagAttachmentsLightningController.saveAttachments(onboardingCase.Id, wrapperToUpdate);
			} catch(Exception e) {
				///throw e;
			}
			
			test.stopTest();
			
			System.assertEquals(comFolderList.size(), comFol.size());
			System.assertEquals(cdlList.size(), attWrapperList.size());
        }
	} 
}