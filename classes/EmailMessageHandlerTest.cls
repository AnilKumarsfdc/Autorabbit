/* --------------------------------------------------------------------------------------------------
   Name:            EmailMessageHandlerTest.cls 
   Description:     Test class for EmailMessageHandler
 --------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData = false)
private class EmailMessageHandlerTest {
    
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final List<String> TO_ADDRESS = new List<String> { 'someaddress@email.com' }; 
    private static final List<String> GDPR_STATUS = new List<String> { 'Closed (Upheld)', 'Closed (Declined)', 'Closed'}; 
    private static final String GDPR_RTBF_SUBJECT = 'GDPR Right to be Forgotten Case Number :';
    private static final String GDPR_RTDP_SUBJECT = 'GDPR Right to Data Portability Case Number :';
	private static final String FROM_NAME = 'FirstName LastName';
	private static final String FROM_ADDRESS = 'someaddress@email.com';
    private static final String DOT = '.';
	private static final String HTML_BODY = 'Test HTML body';
    
    /**
     * @description Email for RTBF Case Closed Accept
     **/
    @isTest private static void updateRTBFCaseTestMethod() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
               

        system.runAs(user) {
            Account acct = PrepareTestData.getDefaultAccount();
        	Database.insert(acct);
            
            Contact conObj = PrepareTestData.getTestContact(acct.Id);
            Database.insert(conObj);
            
            Id rtbfRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.RTBF_RECORD_TYPE).getRecordTypeId();
            
            Case caseObj = new Case(AccountId=acct.Id, RecordTypeId=rtbfRecordType, ContactId= conObj.Id,
                                   Status='Open');
        	Database.insert(caseObj);
            
            Case caseQuery = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            Messaging.InboundEmail inEmail = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            inEmail.subject = GDPR_RTBF_SUBJECT + caseQuery.CaseNumber;
  			inEmail.fromname = FROM_NAME;
            inEmail.plainTextBody = GlobalConstants.RTBF_CLOSED_UPHELD + DOT;
            inEmail.htmlBody = HTML_BODY;
            inEmail.toAddresses = TO_ADDRESS;
  			env.fromAddress = FROM_ADDRESS;
            
            EmailMessageHandler emailService = new EmailMessageHandler();

            Test.startTest();
            	emailService.handleInboundEmail(inEmail, env);
            Test.stopTest();
            
            Case resultCase = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            system.assertEquals(GDPR_STATUS[0], resultCase.Status);
        }
    }
    
    /**
     * @description Email for RTBF Case Closed Decline
     **/
    @isTest private static void declineRTBFCaseTestMethod() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
               

        system.runAs(user) {
            Account acct = PrepareTestData.getDefaultAccount();
        	Database.insert(acct);
            
            Contact conObj = PrepareTestData.getTestContact(acct.Id);
            Database.insert(conObj);
            
            Id rtbfRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.RTBF_RECORD_TYPE).getRecordTypeId();
            
            Case caseObj = new Case(AccountId=acct.Id, RecordTypeId=rtbfRecordType, ContactId= conObj.Id,
                                   Status='Open');
        	Database.insert(caseObj);
            
            Case caseQuery = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            Messaging.InboundEmail inEmail = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            inEmail.subject = GDPR_RTBF_SUBJECT + caseQuery.CaseNumber;
  			inEmail.fromname = FROM_NAME;
            inEmail.plainTextBody = GlobalConstants.RTBF_CLOSED_DECLINED + DOT;
            inEmail.htmlBody = HTML_BODY;
            inEmail.toAddresses = TO_ADDRESS;
  			env.fromAddress = FROM_ADDRESS;
            
            EmailMessageHandler emailService = new EmailMessageHandler();

            Test.startTest();
            	emailService.handleInboundEmail(inEmail, env);
            Test.stopTest();
            
            Case resultCase = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            system.assertEquals(GDPR_STATUS[1], resultCase.Status);
        }
    }
    
    /**
     * @description Email for Data Portability Case Closed
     **/
    @isTest private static void updateRTDPCaseTestMethod() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
               

        system.runAs(user) {
            Account acct = PrepareTestData.getDefaultAccount();
        	Database.insert(acct);
            
            Contact conObj = PrepareTestData.getTestContact(acct.Id);
            Database.insert(conObj);
            
            Id rtbfRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.RTDP_RECORD_TYPE).getRecordTypeId();
            
            Case caseObj = new Case(AccountId=acct.Id, RecordTypeId=rtbfRecordType, ContactId= conObj.Id,
                                   Status='Open');
        	Database.insert(caseObj);
            
            Case caseQuery = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            Messaging.InboundEmail inEmail = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            inEmail.subject = GDPR_RTDP_SUBJECT +caseQuery.CaseNumber;
  			inEmail.fromname = FROM_NAME;
            inEmail.plainTextBody = GlobalConstants.RTDP_CLOSED_CLOSED;
            inEmail.htmlBody = HTML_BODY;
            inEmail.toAddresses = TO_ADDRESS;
  			env.fromAddress = FROM_ADDRESS;
            
            EmailMessageHandler emailService = new EmailMessageHandler();

            Test.startTest();
            	emailService.handleInboundEmail(inEmail, env);
            Test.stopTest();
            
            Case resultCase = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            system.assertEquals(GDPR_STATUS[2], resultCase.Status);
        }
    }
}