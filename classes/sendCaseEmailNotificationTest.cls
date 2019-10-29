/* --------------------------------------------------------------------------------------------------
Name:            sendCaseEmailNotificationTest.cls 
Description:     Test Class for sendCaseEmailNotification  
Created By:      Suman Priya
------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
Private class sendCaseEmailNotificationTest {
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final String PROSPECT_COMPANY_RECORD_TYPE = 'Prospect';
    private static final String CUSTOMER_COMPANY_RECORD_TYPE = 'Customer';
    private static final String SR_CASE_RECORD_TYPE = 'Servicing Request';
    private static final String DOC_TYPE = 'KYC';
    private static final String SHARE_TYPE = 'I';
    private static final String CONTENT_LOCATION = 'S';
    
    /**
     * @description This method runs positive tests 
     **/
    @isTest private static void runPositiveTests() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        String name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        string description = 'CAT Form'; 
        system.runAs(user) {
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
            Schema.DescribeSObjectResult cfrCaseSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrCaseSchema.getRecordTypeInfosByName();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            List<Case> caseList = new List<Case> ();
            List<Account> accList = new List<Account> ();
			List<ContentDocumentLink> conDocList = new List<ContentDocumentLink>();
            
            Account acct = new Account(Name = 'Prospect Company Test', DunsNumber = '516',
                                       RecordTypeId = accountRecordTypeInfo.get(PROSPECT_COMPANY_RECORD_TYPE).getRecordTypeId());
            accList.add(acct);
            Account acct1 = new Account(Name = 'Test');
            accList.add(acct1);
            Database.insert(accList);
            
            Case onboardingCase1 = new Case(AccountId = acct.Id, Status='Pre AOS', J_Number__c = 'J123456',
                                            RecordTypeId = caseRecordTypeInfo.get(SR_CASE_RECORD_TYPE).getRecordTypeId());
            caseList.add(onboardingCase1);
            
            Case onboardingCase2 = new Case(AccountId = acct.Id, Status='Pre AOS', J_Number__c = 'J123457',
                                            RecordTypeId = caseRecordTypeInfo.get(SR_CASE_RECORD_TYPE).getRecordTypeId());
            caseList.add(onboardingCase2);
            Database.insert(caseList);
            
            
            
            ContentVersion conVers = new ContentVersion();
            conVers.ContentLocation = CONTENT_LOCATION;
            conVers.VersionData = bodyBlob;
            conVers.Title = name;
            conVers.PathOnClient = name;
            conVers.Description = description;
            Database.insert(conVers);
            
            
            conVers = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVers.Id LIMIT 10000];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVers.Id LIMIT 1000].ContentDocumentId;
            cdl.LinkedEntityId = onboardingCase1.Id;
            cdl.ShareType = SHARE_TYPE;
            cdlList.add(cdl);
            
            Database.insert(cdlList); 
            
            
            Test.startTest();
            conDocList = sendCaseEmailNotification.getAttachments(onboardingCase1.Id);
            sendCaseEmailNotification.sendCaseEmail(onboardingCase1.Id);
            Test.stopTest();
            System.assertEquals(1, conDocList.size()); 
        }
    }
    
    /**
     * @description This method runs negative tests 
     **/
    @isTest private static void runNegativeTests() {
        
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        String name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        string description = 'Test Description';
        system.runAs(user) {
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
            Schema.DescribeSObjectResult cfrCaseSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrCaseSchema.getRecordTypeInfosByName();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            List<Case> caseList = new List<Case> ();
            List<Account> accList = new List<Account> ();
            
            Account acct = new Account(Name = 'Prospect Company Test', DunsNumber = '516',
                                       RecordTypeId = accountRecordTypeInfo.get(PROSPECT_COMPANY_RECORD_TYPE).getRecordTypeId());
            accList.add(acct);
            Account acct1 = new Account(Name = 'Test');
            accList.add(acct1);
            Database.insert(accList);
            
            Case onboardingCase1 = new Case(AccountId = acct.Id, Status='Pre AOS', J_Number__c = 'J123456',
                                            RecordTypeId = caseRecordTypeInfo.get(SR_CASE_RECORD_TYPE).getRecordTypeId());
            caseList.add(onboardingCase1);
            
            Case onboardingCase2 = new Case(AccountId = acct.Id, Status='Pre AOS', J_Number__c = 'J123457',
                                            RecordTypeId = caseRecordTypeInfo.get(SR_CASE_RECORD_TYPE).getRecordTypeId());
            caseList.add(onboardingCase2);
            Database.insert(caseList);
            
            
            
            ContentVersion conVers = new ContentVersion();
            conVers.ContentLocation = CONTENT_LOCATION;
            conVers.VersionData = bodyBlob;
            conVers.Title = name;
            conVers.PathOnClient = name;
            conVers.Description = NULL;
            Database.insert(conVers);
            
            
            conVers = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVers.Id LIMIT 10000];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVers.Id LIMIT 1000].ContentDocumentId;
            cdl.LinkedEntityId = onboardingCase1.Id;
            cdl.ShareType = SHARE_TYPE;
            cdlList.add(cdl);
            
            Database.insert(cdlList); 
            
            
            Test.startTest();
            try{
                sendCaseEmailNotification.sendCaseEmail(onboardingCase1.Id);
            } catch(Exception e) {
                //throw e;
            }
            
            Test.stopTest();
        }
        
    }
    
}